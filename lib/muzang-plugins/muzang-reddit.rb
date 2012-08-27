require "em-http-request"
require "rss/1.0"
require "rss/2.0"

module Muzang
  module Plugins
    class Reddit
      include Muzang::Plugins::Helpers
      attr_accessor :last_update

      def initialize(bot)
        @bot = bot
        create_database("last_update.yml", Time.now, :last_update)
      end

      def call(connection, message)
        on_join(connection, message) do
          EventMachine::add_periodic_timer(period) do
            http = EventMachine::HttpRequest.new('http://www.reddit.com/r/ruby/.rss').get

            http.callback {
              rss = RSS::Parser.parse(http.response, false)
              rss.items.each do |item|
                connection.msg(message.channel, "#{item.title} | #{item.link}") if item.date > @last_update
              end
              save(rss)
            }
          end
        end
      end

      def save(rss)
        @last_update = rss.items.max_by{|i|i.date}.date
        file = File.open(@config + "/last_update.yml", "w"){|f| f.write YAML::dump(@last_update)}
      end

      def period
        30
      end
    end
  end
end
