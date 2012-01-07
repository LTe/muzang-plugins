module Muzang
  module Plugins
    module Helpers
      def on_channel(message)
        yield message.channel if message.channel
      end

      def match(message, regexp)
        message.message.match(regexp) do |match|
          yield match
        end
      end

      def on_join(connection, message)
        if message.command == :join && message.nick == connection.nick
          yield
        end
      end

      def create_database(file, container, variable)
        unless File.exist?(@config = ENV["HOME"] + "/.muzang")
          FileUtils.mkdir @config
        end

        unless File.exist? @config + "/#{file}"
          db = YAML.dump container
          File.open(@config + "/#{file}", "w"){|f| f.write(db)}
        end

        send(:"#{variable}=", YAML.load(File.open(@config + "/#{file}", "r").read))

        unless self.respond_to?(:save)
          self.class.send(:define_method, :save) do
            File.open(@config + "/#{file}", "w"){|f| f.write YAML.dump(send(variable))}
          end
        end
      end
    end
  end
end
