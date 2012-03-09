require 'spec_helper'
require 'muzang-plugins/muzang-soupirc'

describe "Soup" do
  before do
    @bot = stub(:channels => ["#test"])
    @soup = SoupIRC.new(@bot, ["drugpl", "super_password"])
    @connection = ConnectionMock.new
    @message = OpenStruct.new({:channel => "#test", :message => "!soup http://example.com/image.jpg", :nick => "LTe"})

  end

  it "should send image to soup" do
    Soup::Client.any_instance.stub(:login)
    Soup::Client.any_instance.stub(:new_image).with("http://example.com/image.jpg")

    EM.run do
      @soup.call(@connection, @message)
      eventually(true) do
        @connection.messages.include?("soup updated :) | http://drugpl.soup.io/")
      end
    end
  end
end
