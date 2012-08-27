require "em-http-request"
require "json"
require "memetron"
require "soup-client"

module Muzang
  module Plugins
    class Meme
      include Muzang::Plugins::Helpers

      MEMES = {
        dos_equis:    { image_id: 2485,     generator: 74   },
        y_u_no?:      { image_id: 166088,   generator: 2    },
        bear_grylls:  { image_id: 89714,    generator: 92   },
        fry:          { image_id: 84688,    generator: 305  },
        orly:         { image_id: 117049,   generator: 920  },
        all:          { image_id: 1121885,  generator: 6013 },
        obama:        { image_id: 2154021,  generator: 372781 }
      }

      def initialize(bot)
        @bot      = bot
        @matcher  = Memetron::Matcher.new
        @soup     = File.open(ENV["HOME"] + "/.muzang/" + "soup").read.split(":") rescue nil
      end

      def call(connection, message)
        message.message.match(/^meme$/) do
          connection.msg("#{@bot.channels.first}", "Type 'meme [name of meme] \"Text0\" \"Text1\"'")
          connection.msg("#{@bot.channels.first}", "Available memes: #{MEMES.keys.join(" ")}")
        end
        message.message.match(/^meme (.*?) "(.*?)"( "(.*?)")?$/) do |m|
          if meme_ids = MEMES[m[1].to_sym]
            @generator = meme_ids[:generator]
            @image_id  = meme_ids[:image_id]
          else
            return nil
          end

          @text0 = m[2]
          @text1 = m[4]
          
          create_instance(connection)
        end
      
        on_channel(message) do
          if meme = @matcher.match_and_parse(message.message)
            @generator = MEMES[meme.first][:generator]
            @image_id  = MEMES[meme.first][:image_id]

            case meme.first
              when :dos_equis
                @text0 = "I don't always #{meme[1][0]}"
                @text1 = "but when I do #{meme[1][1]}"
              when :y_u_no?
                @text0 = meme[1][0] + "Y U NO"
                @text1 = meme[1][1]
              when :bear_grylls
                @text0 = meme[1][0]
                @text1 = "better drink my own piss"
              when :fry
                @text0 = "not sure if #{meme[1][1]}"
                @text1 = "or #{meme[1][2]}"
              when :orly
                @text0 = meme[1][0]
                @text1 = "ORLY?"
              when :all
                @text0 = meme[1][0]
                @text1 = "all the things!"
              when :obama
                @text0 = meme[1][0]
                @text1 = "not bad"
              else
                @text0 = meme[1][0]
                @text1 = meme[1][1]
            end
              create_instance(connection)
            end
        end 
      end

      def create_instance(connection)
        http = EventMachine::HttpRequest.new('http://version1.api.memegenerator.net/Instance_Create')
               .get(:query => {:username => 'drug-bot',
                               :password => 'drug-bot',
                               :languageCode => 'en',
                               :generatorID => @generator,
                               :imageID => @image_id,
                               :text0 => @text0,
                               :text1 => @text1})

        http.callback {
          meme = JSON.parse(http.response)
          instance = meme['result']['instanceImageUrl']

          if instance.include?("images")
            url = instance
          else
            url = "http://iversion1.api.memegenerator.net#{instance}"
          end

          connection.msg("#{@bot.channels.first}", "Meme: #{url}")
          if @soup
            soup = Soup::Client.new(@soup.first, @soup.last.chomp)
            soup.login
            soup.new_image(url)
          end
        }
      end
    end
  end
end
