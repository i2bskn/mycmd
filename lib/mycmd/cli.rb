# coding: utf-8

require "mycmd/cli/config_commands"
require "mycmd/cli/settings_commands"
require "mycmd/cli/status_commands"

module Mycmd
  class CLI < Thor
    default_command :console
    register(ConfigCommands, "config", "config [COMMAND]", "commands for config")
    register(SettingsCommands, "settings", "settings [COMMAND]", "commands for settings")
    register(StatusCommands, "status", "status [COMMAND]", "commands for status")

    desc "console", "console will start sql shell."
    def console
      begin
        raise "mysql command not found" unless Kernel.system("which mysql > /dev/null")
        Kernel.system(Client.command)
      rescue => e
        puts e.message
      end
    end

    desc 'query "[SQL]"', "query will execute sql."
    def query(sql)
      begin
        Client.query(sql).print
      rescue => e
        puts e.message
      end
    end

    desc 'tasks [TASK NAME]p', "tasks will execute register sql."
    option :list, aliases: "-l", desc: "Display the tasks"
    def tasks(task=nil)
      if options[:list].nil?
        begin
          Client.execute_task(task).print
        rescue => e
          puts e.message
        end
      else
        conf = Configuration.new
        if conf.tasks.nil?
          puts "task is not registered"
        else
          conf.tasks.each{|k,v| puts "#{k}:\t#{v}"}
        end
      end
    end
  end
end