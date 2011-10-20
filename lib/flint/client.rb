module Flint
  class Client < EventMachine::HttpClient
    attr_accessor :connection

    def initialize
      @state    = :initializing
      @handlers = {}
      @token    = nil
      @account  = nil
      @room_id  = nil
      @buffer   = ""
    end

    def register_handler(type, gaurd, &block)
      @handlers[type] ||= []
      @handlers[type] << [gaurd, block]
    end

    def setup(token, account, room_id)
      @token   = token
      @account = account
      @room_id = room_id
      self
    end

    def run
      trap(:INT)  { EventMachine.stop }
      trap(:TERM) { EventMachine.stop }

      EventMachine.run { join }

      @state = :setup
    end

    def join
      headers = { "authorization" => [@token, "X"] }
      @connection = EventMachine::HttpRequest.new("https://#{@account}.campfirenow.com/room/#{@room_id}/join.json").post(:head => headers)
      @connection.headers { |headers| listen }
    end

    def listen
      headers = { "authorization" => [@token, "X"] }
      @connection = EventMachine::HttpRequest.new("https://streaming.campfirenow.com/room/#{@room_id}/live.json").get(:head => headers)
      @connection.headers { |headers| handle_ready }
      @connection.stream  { |chunk| process(chunk) unless chunk.blank? }
    end

    def say(message)
      return if @state == :initializing
      
      headers = { "authorization" => [@token, "X"] }
      message = { :message => message }
      EventMachine::HttpRequest.new("https://#{@account}.campfirenow.com/room/#{@room_id}/speak.json").post(:head => headers, :query => message)
    end

    def handle_ready
      Array(@handlers[:ready]).each { |_, block| block.call }
      @state = :ready
    end

    def process(chunk)
      @buffer += chunk
      while line = @buffer.slice!(/.*\r/)
        message = JSON.parse(line).with_indifferent_access rescue nil
        handle_message(message) if message
      end
    end

    def handle_message(message)
      Array(@handlers[:message]).each do |guard, block|
        block.call(message) if guarded?(guard, message)
      end
    end

    def guarded?(guard, message)
      guard.all? do |attribute, test|
        case test
        when String then message[attribute] == test
        when Regexp then message[attribute] =~ test
        when Array  then test.include?(message[attribute])
        when Proc   then test.call(message[attribute])
        else false
        end
      end
    end
  end
end