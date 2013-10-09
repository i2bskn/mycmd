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
      raise "mysql not found" unless Kernel.system("which mysql > /dev/null")
      conf = Configuration.new
      cmd = conf.to_hash.inject(["mysql"]) do |c,(k,v)|
        case k
        when :host then c << "-h#{v}"
        when :port then c << "-P#{v}"
        when :username then c << "-u#{v}"
        when :password then c << "-p#{v}"
        when :database then c << v
        end
      end

      Kernel.system(cmd.join(" "))
    end

    desc 'query "[SQL]"', "query will execute sql."
    def query(sql)
      Client.query(sql).print
    end

    desc 'tasks [TASK NAME]p', "tasks will execute register sql."
    def tasks(task)
      Client.execute_task(task).print
    end
  end
end