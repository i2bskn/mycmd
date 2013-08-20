# coding: utf-8

require "mycmd/clis/config_commands"

module Mycmd
  class CLI < Thor
    default_command :console
    register(ConfigCommands, "config", "config [COMMAND]", "commands for config")

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
      client = Configuration.new.connect
      result = client.query(sql)
      if result.respond_to? :each
        puts result.fields.join("\t")
        result.each(as: :array) do |row|
          puts row.join("\t")
        end
      end
    end
  end
end