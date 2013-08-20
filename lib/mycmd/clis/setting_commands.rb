# coding: utf-8

module Mycmd
  class SettingCommands < Thor
    namespace :setting

    desc "search innodb_buffer_pool_size", "search will print settings"
    def search(keyword)
      client = Configuration.connect
      result = client.query("SHOW GLOBAL VARIABLES LIKE \"%#{keyword}%\"")
      if result.respond_to? :each
        result.each(as: :array) do |row|
          puts row.join("\t")
        end
      end
    end
  end
end
