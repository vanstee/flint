module Flint
  class Client < EventMachine::HttpClient
    attr_accessor :connection, :response, :params

    def initialize
      @state    = :initializing
      @handlers = {}
      @token    = nil
      @account  = nil
      @room_id  = nil
      @buffer   = ""
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

    def register_handler(type, guards, &block)
      (@handlers[type] ||= []) << Client.compile(guards, block)
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
      Array(@handlers[:message]).each do |guards, block|
        @params   = Client.parameterize(guards, message)
        @response = message
        block.call(self) if Client.guarded?(guards, message)
      end
    end

    class << self
      def parameterize(guards, message)
        params = {}.with_indifferent_access
        guards.map do |attribute, test, keys|
          if test.is_a? Regexp and match = message[attribute].match(test)
            params.merge! Hash[match.names.zip(match.captures)]
          end
        end
        params
      end

      def generate_method(method_name, &block)
        define_method(method_name, &block)
        method = instance_method method_name
        remove_method method_name
        method
      end

      def compile(guards, block)
        guards = guards.map do |attribute, test|
          keys = []
          if test.is_a? String
            test = Regexp.quote(test)
            pattern = test.gsub /(:\w+)/ do |match|
              key = $1[1..-1]
              keys << key
              "(?<#{key}>\\w+)"
            end
            [attribute, /^#{pattern}$/, keys]
          else
            [attribute, test, []]
          end
        end

        unbound_method = generate_method("#{guards}", &block)

        [guards, proc { |c| unbound_method.bind(c).call }]
      end

      def guarded?(guards, message)
        guards.all? do |attribute, test|
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
end