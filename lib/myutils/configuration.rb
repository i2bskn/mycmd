# coding: utf-8

module Myutils
  class Configuration
    CONFIG_FILE = ".myutils.yml"

    VALID_OPTIONS_KEYS = [
      :host,
      :username,
      :password,
      :port,
      :database,
      :socket,
      :flags,
      :encoding,
      :read_timeout,
      :write_timeout,
      :connect_timeout,
      :reconnect,
      :local_infile,
    ].freeze

    attr_accessor *VALID_OPTIONS_KEYS

    def initialize
      reset
    end

    def config_find(path = File.expand_path("."))
      file = File.join(path, CONFIG_FILE)
      if File.exists?(file)
        file
      else
        if path == "/"
          file = File.join(ENV["HOME"], CONFIG_FILE)
          File.exists?(file) ? file : nil
        else
          config_find(File.expand_path("..", path))
        end
      end
    end

    def configure
      yield self
    end

    def merge(params)
      params.each do |k,v|
        self.send("#{k.to_s}=", v)
      end
    end

    def to_hash
      VALID_OPTIONS_KEYS.inject({}) do |c,k|
        c.store(k.to_sym, self.send(k.to_s)) unless self.send(k.to_s).nil?
        c
      end
    end

    def connect
      Mysql2::Client.new(to_hash)
    end

    def reset
      file = config_find
      if file
        merge YAML.load_file(file)
      else
        self.host = "localhost"
        self.port = 3306
        self.username = "root"
      end
    end
  end
end