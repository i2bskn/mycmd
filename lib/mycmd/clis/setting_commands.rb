# coding: utf-8

module Mycmd
  class SettingCommands < Thor
    namespace :setting

    desc "search innodb_buffer_pool_size", "search will print settings"
    def search(keyword)
      client = Configuration.connect
      printer = Printer.new(client.query("SHOW GLOBAL VARIABLES LIKE \"%#{keyword}%\""))
      printer.print
    end
  end
end
