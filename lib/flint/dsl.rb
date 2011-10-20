module Flint
  module DSL
    def client
      @client ||= Client.new
    end
    module_function :client

    def setup(token, account, room_id)
      client.setup(token, account, room_id)
    end

    def ready(&block)
      client.register_handler(:ready, nil, &block)
    end

    def message(gaurd, &block)
      client.register_handler(:message, gaurd, &block)
    end

    def say(message)
      client.say(message)
    end
  end
end