require 'spec_helper'

describe Flint::Client do
  before do
    @client = Flint::Client.new
  end

  it 'can be setup' do
    @client.setup('token', 'account', 'room').should == @client
  end

  describe "#initialize" do
    it 'sets the state to :initializing' do
      @client.state.should == :initializing
    end
  end

  describe '#message' do
    before do
      @client = Flint::Client.new
    end

    it 'can be a hash with string match' do
      response = mock()
      response.should_receive(:call)
      @client.register_handler(:message, :body => "Taco party?") { response.call }

      @client.handle_message(:body => "Taco party?")
    end

    it 'can be a hash with a regexp' do
      response = mock()
      response.should_receive(:call)
      @client.register_handler(:message, :body => /tacos/) { response.call }

      @client.handle_message(:body => "So we\'re going to eat tacos for lunch 4 days in a row")
    end

    it 'can be a hash with an array' do
      response = mock()
      response.should_receive(:call)
      @client.register_handler(:message, :body => ["Taqueria del Sol", "Taco Bell", "Del Taco"]) { response.call }

      @client.handle_message(:body => "Taqueria del Sol")
    end

    it 'can be a hash with a lambda' do
      response = mock()
      response.should_receive(:call)
      @client.register_handler(:message, :body => lambda { |body| body.length == 30 }) { response.call }

      @client.handle_message(:body => "What\'s the blue plate special?")
    end

    it 'can define a param to match' do
      param = 'queso'
      response = mock()
      response.should_receive(:call).with(param)
      @client.register_handler(:message, :body => 'This :side tastes so good with these tacos') { response.call(params[:side]) }

      @client.handle_message(:body => "This #{param} tastes so good with these tacos")
    end

    it 'returns the response in the scope of the block' do
      message = 'Everyone bought an extra rouge cheese dip. Win!'
      mock = mock()
      mock.should_receive(:call).with(message)
      @client.register_handler(:message, :body => /rouge cheese dip/) { mock.call(response[:body]) }

      @client.handle_message(:body => message)
    end
  end
end