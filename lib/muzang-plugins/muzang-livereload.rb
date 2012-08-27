module Muzang
  module Plugins
    class LiveReload
      include Muzang::Plugins::Helpers

      def initialize(bot)
        @bot = bot
      end

      def call(connection, message)
        on_channel(message) do
          match(message, /^!reload$/) do
            @bot.plugins.each do |plugin, instance|
              Kernel.load("muzang-plugins/muzang-#{plugin.to_s.split("::").last.downcase}.rb")
              instance = plugin.new(@bot)
              connection.msg(message.channel, "Reloading: #{plugin}")
            end
          end
        end
      end
    end
  end
end
