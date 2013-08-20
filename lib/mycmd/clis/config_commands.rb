# coding: utf-8

module Mycmd
  class ConfigCommands < Thor
    namespace :config

    desc "which", "which will find config file"
    def which
      conf = Configuration.new
      path = conf.path.nil? ? "config not found" : conf.path
      puts path
    end

    desc "cat", "cat will print configuration"
    def cat
      conf = Configuration.new
      raise "config not found" if conf.path.nil?
      open(conf.path, "r").each do |line|
        puts line
      end
    end

    desc "edit", "edit will edit configuration"
    def edit
      conf = Configuration.new
      raise "config not found" if conf.path.nil?
      system("#{ENV['EDITOR']} #{conf.path}")
    end
  end
end
