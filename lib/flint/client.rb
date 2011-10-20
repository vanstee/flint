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

    def setup(token, account, room_id)
      @token   = token
      @account = account
      @room_id = room_id
      self
    end
  end
end