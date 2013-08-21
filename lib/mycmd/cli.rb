# coding: utf-8

require "mycmd/clis/config_commands"
require "mycmd/clis/settings_commands"

module Mycmd
  class CLI < Thor
    default_command :console
    register(ConfigCommands, "config", "config [COMMAND]", "commands for config")
    register(SettingsCommands, "settings", "settings [COMMAND]", "commands for settings")

    desc "console", "console will start sql shell."
    def console
      raise "mysql not found" unless system("which mysql > /dev/null")
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

      system(cmd.join(" "))
    end

    desc 'query "[SQL]"', "query will execute sql."
    def query(sql)
      client = Configuration.connect
      printer = Printer.new(client.query(sql), true)
      printer.print
    end

    desc 'tasks [TASK NAME]', "tasks will execute register sql."
    def tasks(task)
      config = Configuration.new
      client = config.connect
      printer = Printer.new(client.query(config.tasks[task.to_s]), true)
      printer.print
    end
  end
end