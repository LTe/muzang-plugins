require "em-http-request"
require "json"
require "pstore"

class RubyGems
  include Muzang::Plugins::Helpers

  attr_accessor :last_gem, :store

  def initialize(bot)
    @bot = bot
    @store = PStore.new("#{ENV["HOME"]}/.muzang/muzang.rubygems")
    @store.transaction do
      @store[:gems] ||= {}
    end
  end

  def call(connection, message)
    match(message, /^watch! (.*?)$/) do |match|
      @current_gem = match[1]

      @store.transaction do
        unless @store[:gems][@current_gem]
          @store[:gems][match[1]] = {:name => @current_gem}
          @new_gem = true
        end
      end

      if @new_gem
        http = EventMachine::HttpRequest.new("http://rubygems.org/api/v1/gems/#{@current_gem}.json").get
        http.callback {
          begin
            gem = JSON.parse(http.response)
            @store.transaction do
              @store[:gems][@current_gem][:version] = gem["version"]
            end
            connection.msg(message.channel, "I added gem #{@current_gem} to watchlist")
            connection.msg(message.channel, "Current version: #{@current_gem} (#{gem["version"]})")
            @new_gem = false
          rescue Exception
            connection.msg(message.channel, "Gem name is incorrect")
            @store.transaction{@store[:gems].delete(@current_gem)}
          end
        }
      else
        connection.msg(message.channel, "Gem #{@current_gem} is already observed")
      end
    end

    match(message, /^!cojapacze$/) do
      @store.transaction do
        connection.msg(message.channel, "#{@store[:gems].keys.join(', ')}")
      end
    end

    on_join(connection, message) do
      EventMachine.add_periodic_timer(period) do
        gems = @store.transaction{@store[:gems].values}
        EM::Iterator.new(gems, 1).each do |gem, iter|
          http = EventMachine::HttpRequest.new("http://rubygems.org/api/v1/gems/#{gem[:name]}.json").get
          http.callback {
            iter.next
            begin
              current_gem = JSON.parse(http.response)
              if Gem::Version.new(gem[:version]) < Gem::Version.new(current_gem["version"])
                @store.transaction do
                  @store[:gems][gem[:name]][:version] = current_gem["version"]
                end
                connection.msg(message.channel, "New version #{gem[:name]} (#{current_gem["version"]})")
              end
            rescue
            end
          }
        end
      end
    end
  end

  def period
    30
  end
end
