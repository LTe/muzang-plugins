require 'sqlite3'
require 'active_record'
require 'pastie-api'

class Grep
  include Muzang::Plugins::Helpers

  DATABASE_FILE = 'irclog.sqlite3'
  DATABASE_CONFIG = {
    :database => 'irclog.sqlite3',
    :encoding => 'utf8',
    :adapter => 'sqlite3'
  }

  class Message < ActiveRecord::Base
    def self.like(channel, term)
      find(:all, :conditions => ['channel LIKE ? AND content MATCH ?' , channel, term], :order => 'created_at DESC', :limit => 20)
    end

    def to_text
      ["## #{user} @ #{created_at}:", content, ''].join("\n")
    end

    class Migration < ActiveRecord::Migration
      def self.up
        execute(%q{
  CREATE VIRTUAL TABLE messages USING fts4(
    channel VARCHAR(255) NOT NULL,
    user VARCHAR(255) NOT NULL,
    content VARCHAR(2048) NOT NULL,
    created_at DATETIME NOT NULL);
  })
      end

      def self.down
        drop_table :messages
      end
    end
  end

  def initialize(bot)
    @bot = bot
    open_database
  end

  def call(connection, message)
    on_channel(message) do
      match(message, /^[^~(Searched)]/) do
        persist_message(message)
      end
      match(message, /^~ (.*)/) do |what|
        search_for_term(connection, message, what[1])
      end
    end
  rescue
    puts $!
    puts $!.backtrace
    raise
  end

  def persist_message(message)
    Message.create!(:channel => message.channel,
                    :user => message.user,
                    :content => message.message)
  end

  def search_for_term(connection, message, term)
    results = Message.like(message.channel, term)
    if results.size > 0
      link = save_results(term, results)
      connection.msg(message.channel, "Searched for '#{term}', found #{results.size} matches: #{link}")
    else
      connection.msg(message.channel, "Searched for '#{term}', nothing found")
    end
  end

  private
  def open_database
    initialize_database unless database_exists?
    open_existing_database
  end

  def database_exists?
    File.exists?(DATABASE_FILE)
  end

  def initialize_database
    ActiveRecord::Base.establish_connection(DATABASE_CONFIG)
    Message::Migration.up
    ActiveRecord::Base.connection.disconnect!
  end

  def open_existing_database
    ActiveRecord::Base.establish_connection(DATABASE_CONFIG)
  end

  def save_results(term, results)
    content = ["Searched for '#{term}', found #{results.size} matches", '']
    content += results.map(&:to_text)
    Pastie.create(content.join("\n"), false).link
  end
end
