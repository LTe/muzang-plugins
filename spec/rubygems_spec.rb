require 'spec_helper'
require 'muzang-plugins/muzang-rubygems'

module Muzang::Plugins
  class RubyGems
    def period
      0.1
    end
  end

  describe "RubyGems" do
    before do
      @bot = stub
      @rubygems = RubyGems.new(@bot)
      @connection = ConnectionMock.new(:nick => "DRUG-bot")
      @message = OpenStruct.new({ :command => :prvmsg, :channel => "#test", :nick => "DRUG-bot" })
      @gem = File.expand_path('../support/responses/acts-as-messageable.response', __FILE__)
      @gem2 = File.expand_path('../support/responses/acts-as-messageable2.response', __FILE__)
      EventMachine::MockHttpRequest.pass_through_requests = true
      EventMachine::MockHttpRequest.register_file('http://rubygems.org:80/api/v1/gems/acts-as-messageable.json', :get, @gem)
      EventMachine::MockHttpRequest.register_file('http://rubygems.org:80/api/v1/gems/acts-as-messageable2.json', :get, @gem2)
      EventMachine::MockHttpRequest.activate!
    end

    after do
      FileUtils.rm("#{ENV["HOME"]}/.muzang/muzang.rubygems")
    end

    it "should add gem to watching list with watch! command" do
      @message.message = "!watch acts-as-messageable"
      EM.run do
        @rubygems.call(@connection, @message)
        eventually(true, :times => 10) do
          @connection.messages.include? "I added gem acts-as-messageable to watchlist" and
          @connection.messages.include? "Current version: acts-as-messageable (0.4.2)"
        end
      end
    end

    it "should remove gem from watching list" do
      @message.message = "!watch acts-as-messageable"
      EM.run do
        @rubygems.call(@connection, @message)
        @message.message = "!unwatch acts-as-messageable"
        @rubygems.call(@connection, @message)

        eventually(true, :times => 10) do
          @connection.messages.include? "I removed gem acts-as-messageable from watchlist"
        end
      end
    end

    it "should raise error" do
      @message.message = "!watch acts-as-messageable2"
      EM.run do
        @rubygems.call(@connection, @message)
        eventually(true) do
          @connection.messages.include? "Gem name is incorrect"
        end
      end
    end

    it "should not add gem twice to store" do
      @message.message = "!watch acts-as-messageable"
      EM.run do
        2.times{ @rubygems.call(@connection, @message) }
        eventually(true) do
          @connection.messages.include? "Gem acts-as-messageable is already observed"
        end
      end
    end

    it "should remove gem from storage" do
      @message.message = "!watch acts-as-messageable2"
      EM.run do
        @rubygems.call(@connection, @message)
        eventually(true) do
          @rubygems.store.transaction do
            @rubygems.store[:gems]["acts-as-messageable2"] == nil
          end
        end
      end
    end

    it "should notice about new version of gem" do
      @message.message = ""
      @message.command = :join

      EM.run do
        @rubygems.call(@connection, @message)
        @message.message = "!watch acts-as-messageable"
        @rubygems.call(@connection, @message)

        @rubygems.store.transaction{ @rubygems.store[:gems]["acts-as-messageable"][:version] = "0.4.1" }

        eventually(true, :every => 0.1, :total => 100) do
          @connection.messages.include? "New version acts-as-messageable (0.4.2)"
        end
      end
    end

    it "should list watched gems" do
      @message.message = "!cojapacze"
      @rubygems.store.transaction do
        @rubygems.store[:gems]["gem1"] = { :name => "gem1" }
        @rubygems.store[:gems]["gem2"] = { :name => "gem2" }
      end

      EM.run do
        @rubygems.call(@connection, @message)
        eventually(true) do
          @connection.messages.include? "gem1, gem2"
        end
      end
    end
  end
end
