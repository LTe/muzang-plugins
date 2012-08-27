require 'spec_helper'
require 'muzang-plugins/muzang-reddit'

module Muzang::Plugins
  class Reddit
    def period
      0.1
    end
  end

  describe "Reddit" do
    before do
      @bot = stub
      @reddit = Reddit.new(@bot)
      @connection = ConnectionMock.new(:nick => "DRUG-bot")
      @message = OpenStruct.new({ :command => :join, :channel => "#test", :nick => "DRUG-bot" })
      @file = File.expand_path('../support/responses/reddit.response', __FILE__)
      EventMachine::MockHttpRequest.pass_through_requests = false
      EventMachine::MockHttpRequest.register_file('http://www.reddit.com:80/r/ruby/.rss', :get, @file)
      EventMachine::MockHttpRequest.activate!
    end

    it "should call reddit and print all articles" do
      @reddit.last_update = Time.new 2010
      EM.run do
        @reddit.call(@connection, @message)
        eventually(25) { @connection.message_count }
      end
    end

    it "should print only one message" do
      @reddit.last_update = (DateTime.parse "Thu, 29 Sep 2011 00:47:00 +0200").to_time
      EM.run do
        @reddit.call(@connection, @message)
        eventually(1, :every => 0.1, :total => 20) { @connection.message_count }
      end
    end

    it "should not print message" do
      @reddit.last_update = Time.now
      EM.run do
        @reddit.call(@connection, @message)
        eventually(0) { @connection.message_count }
      end
    end
  end
end
