require 'spec_helper'
require 'muzang-plugins/muzang-meme'

URL = "http://version1.api.memegenerator.net:80/Instance_Create?username=drug-bot&password=drug-bot&languageCode=en&generatorID=2&imageID=166088&text0=hi0&text1=hi1"

describe "Meme" do
  let(:bot)         { stub(:channels => ["#test"]) }
  let(:meme)        { Meme.new(bot) }
  let(:connection)  { ConnectionMock.new }
  let(:url)         { URL }
  let(:file)        { File.expand_path("../support/responses/meme.response", __FILE__) }
  let(:message)     { OpenStruct.new({:channel => "#test", :message => "meme", :nick => "LTe" }) }
  
  before do
    EventMachine::MockHttpRequest.pass_through_requests = false
    EventMachine::MockHttpRequest.register_file(url, :get, file)
    EventMachine::MockHttpRequest.activate!
  end

  it "should print pretty help" do
    EM.run do
      meme.call(connection, message)
      eventually(true) do
        connection.messages.include?("Type 'meme [name of meme] \"Text0\" \"Text1\"'") and
        connection.messages.include?("Available memes: #{Meme::MEMES.keys.join(" ")}")
      end
    end
  end

  it "should create meme and send message" do
    message.message = "meme y_u_no? \"hi0\" \"hi1\""
    EM.run do
      meme.call(connection, message)
      eventually(1) { connection.message_count }
      eventually(true) { connection.messages.include? "Meme: http://version1.api.memegenerator.net//cache/instances/400x/10/10725/10982714.jpg" }
    end
  end

  it "should not create meme" do
    message.message = "meme asdkasdj \"hi0\" \"hi1\""
    EM.run do
      meme.call(connection, message)
      eventually(0) { connection.message_count }
    end
  end


  context "meme recognize" do
    before { meme.stub(:create_instance) }

    it "should recognize dos_equis meme" do
      message.message = "I don't always create spec but when I do I do it with rspec"
      EM.run do
        meme.call(connection, message)
        eventually(true) { meme.instance_variable_get(:@text0).should == "I don't always create spec" }
        eventually(true) { meme.instance_variable_get(:@text0).should == "but when I do I do it with rspec" }
      end
    end

    it "should recognize yuno meme" do
      message.message = "LTe Y U NO create specs for it?"
      EM.run do
        meme.call(connection, message)
        eventually(true) { meme.instance_variable_get(:@text0).should == "LTe Y U NO" }
        eventually(true) { meme.instance_variable_get(:@text1).should == "create specs for it?" }
      end
    end
  end
end
