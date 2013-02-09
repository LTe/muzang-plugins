module Muzang
  module Plugins
    class Safe
       def safe(code, sandbox=nil)
         error = nil

         begin
           $-w = nil
           @sandbox ||= Object.new
           yield(@sandbox) if block_given?

           $SAFE = 3
           result = eval(code, @sandbox.send(:binding))
         rescue Exception => error
           error = error
         end

         return result, error
       end
    end

    class Eval
      include Muzang::Plugins::Helpers

      def initialize(bot)
        @bot = bot
      end

      def call(connection, message)
        on_channel(message) do
          match(message, /^\% (.*)/) do |match|
            operation = proc do
              safe(match[1])
            end
            callback = proc do |tuple|
              result, error = tuple
              connection.msg(message.channel, "#{result}") if result
              connection.msg(message.channel, "Error: #{error}") if error
            end
            EM.defer(operation, callback)
          end
        end
      end

      def safe(*args, &block)
        unless args.first =~ /EM|EventMachine/
          @safe ||= Safe.new
          @safe.safe(*args, &block)
        end
      end
    end
  end
end


