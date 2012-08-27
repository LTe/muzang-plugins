require 'spec_helper'
require 'muzang-plugins/muzang-livereload'

module Muzang::Plugins
  describe "LiveReload" do
    before(:each) do
      @bot = stub
      @livereload = LiveReload.new(@bot)
      @bot.stub(:plugins => { LiveReload => @livereload })
      @connection = stub(:msg => true)
      Kernel.stub(:load)
      @message = OpenStruct.new({:channel => "#test", :message => "!reload"})
    end

    it "should load plugins" do
      Kernel.should_receive(:load).with('muzang-plugins/muzang-livereload.rb')
      @livereload.call(@connection, @message)
    end

    it "should create new instance of plugin" do
      LiveReload.should_receive(:new).with(@bot)
      @livereload.call(@connection, @message)
    end
  end
end
