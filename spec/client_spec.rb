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
end