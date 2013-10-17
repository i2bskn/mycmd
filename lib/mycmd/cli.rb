# coding: utf-8

require "mycmd/clis/config_commands"
require "mycmd/clis/settings_commands"
require "mycmd/clis/status_commands"

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
    def tasks(task)
      begin
        Client.execute_task(task).print
      rescue => e
        puts e.message
      end
    end
  end
end