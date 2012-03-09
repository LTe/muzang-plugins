require "soup-client"

class SoupIRC
  include Muzang::Plugins::Helpers

  def initialize(bot, soup=[])
    @bot  = bot
    @soup = soup || File.open(ENV["HOME"] + "/.muzang/" + "soup").read.split(":") rescue nil
  end

  def call(connection, message)
    message.message.match(/^!soup (.*?)$/) do |m|
      soup = Soup::Client.new(@soup.first, @soup.last.chomp)
      soup.login
      soup.new_image(m[1])
      connection.msg(@bot.channels.first, "soup updated :) | http://#{@soup.first}.soup.io/")
    end
  end
end
