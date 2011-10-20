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
      @response = mock()
    end

    it 'can be a hash with string match' do
      @response.should_receive(:call)
      @client.register_handler(:message, :body => "Taco party?") { @response.call }

      @client.handle_message(:body => "Taco party?")
    end

    it 'can be a hash with a regexp' do
      @response.should_receive(:call)
      @client.register_handler(:message, :body => /tacos/) { @response.call }

      @client.handle_message(:body => "So we\'re going to eat tacos for lunch 4 days in a row")
    end

    it 'can be a hash with an array' do
      @response.should_receive(:call)
      @client.register_handler(:message, :body => ["Taqueria del Sol", "Taco Bell", "Del Taco"]) { @response.call }

      @client.handle_message(:body => "Taqueria del Sol")
    end

    it 'can be a hash with a lambda' do
      @response.should_receive(:call)
      @client.register_handler(:message, :body => lambda { |body| body.length == 30 }) { @response.call }

      @client.handle_message(:body => "What\'s the blue plate special?")
    end
  end
end