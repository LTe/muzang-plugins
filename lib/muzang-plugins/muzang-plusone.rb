require 'fileutils'
require 'yaml'

module Muzang
  module Plugins
    class PlusOne
      include Muzang::Plugins::Helpers

      attr_accessor :config, :stats

      def initialize(bot)
        @bot = bot
        create_database("stats.yml", Hash.new, :stats)
      end

      def call(connection, message)
        on_channel(message) do
          match(message, /^([^\s]*) \+1/) do |plus_for|
            plus_for = plus_for[1]
            plus_for.gsub!(":","")
            if filter(plus_for, message.nick)
              connection.msg(message.channel, "#{message.nick} write in PHP") and return
            end

            connection.msg(message.channel, "#{message.nick} gave +1 for *#{plus_for}*")
            @stats[plus_for] ||= 0
            @stats[plus_for]  += 1
            save
          end

          match(message, /^!stats$/) do
            connection.msg(message.channel, print)
          end
        end
      end

      def print
        message = ""
        stat = @stats.sort_by { |points| -points[1] }
        stat.each do |s|
          message << "*#{s[0]}* #{s[1]} | " if s[1] > 0
        end

        message
      end

      def filter(plus_for, nick)
        if plus_for == nick || @stats[nick] == nil
          return true
        end
      end
    end
  end
end
