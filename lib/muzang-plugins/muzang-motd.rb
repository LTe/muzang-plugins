require 'muzang/version'

class Motd
  include Muzang::Plugins::Helpers

  def initialize(bot)
    @bot = bot
  end

  def call(connection, message)
    on_join(connection, message) do
      connection.msg(message.channel, "Muzang | Version: #{Muzang::VERSION} | Plugins: #{plugins}")
    end
  end

  def plugins
    list = ""
    @bot.plugins.each{|plugin, instance| list << "*#{plugin}* "}
    list
  end
end
