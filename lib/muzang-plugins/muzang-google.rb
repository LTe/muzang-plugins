module Muzang
  module Plugins
    class Google
      include Muzang::Plugins::Helpers

      def initialize(bot)
        @bot = bot
      end

      def call(connection, message)
        on_channel(message) do
          message.message.match(/^(!|@)google (.*?)$/) do |m|
            http = EventMachine::HttpRequest.new("http://ajax.googleapis.com/ajax/services/search/web").get :query => { :v => "1.0", :q => m[2] }
            http.callback { 
              results = JSON.parse(http.response)
              result  = results["responseData"]["results"].first
              connection.msg(message.channel, "#{result["url"]} | #{result["titleNoFormatting"]}")
            }
          end
        end
      end
    end
  end
end
