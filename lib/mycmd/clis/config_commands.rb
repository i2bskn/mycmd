# coding: utf-8

module Mycmd
  class ConfigCommands < Thor
    namespace :config

    desc "which", "which will find config file"
    def which
      conf = Configuration.config_find
      puts conf.nil? ? "config not found" : conf
    end

    desc "cat", "cat will print configuration"
    def cat
      begin
        conf = Configuration.config_find
        raise "config not found" if conf.nil?
        File.open(conf, "r").each {|line| puts line}
      rescue => e
        puts e.message
      end
    end

    desc "edit", "edit will edit configuration"
    def edit
      begin
        conf = Configuration.config_find
        raise "config not found" if conf.nil?
        Kernel.system("#{ENV['EDITOR']} #{conf}")
      rescue => e
        puts e.message
      end
    end
  end
end
