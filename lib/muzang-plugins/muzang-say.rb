class Say
  include Muzang::Plugins::Helpers

  def initialize(bot)
    @bot = bot
  end

  def call(connection, message)
    message.match(/^say (.*?)$/) do |match|
    end
  end
end
