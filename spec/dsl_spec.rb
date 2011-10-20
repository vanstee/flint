require 'spec_helper'

describe Flint::DSL do
  before do
    @client = Flint::Client.new
    @dsl = Class.new { include Flint::DSL }.new
    Flint::Client.stub!(:new).and_return(@client)
  end

  it 'wraps the setup' do
    args = ['token', 'account', 'room']
    @client.should_receive(:setup).with(*args)
    @dsl.setup(*args)
  end

  it 'provides a helper for ready state' do
    @client.should_receive(:register_handler).with(:ready, nil)
    @dsl.ready
  end

  it 'sets up handlers' do
    guard = {:from => 'taco@lover.com', :body => 'I love tacos!'}
    @client.should_receive(:register_handler).with(:message, guard)
    @dsl.message(guard)
  end

  it 'provides a "say" helper' do
    message = "Can we get some cheese dip over here?"
    @client.should_receive(:say).with(message)
    @dsl.say(message)
  end
end