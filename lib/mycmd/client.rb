# coding: utf-8

module Mycmd
  class Client
    attr_reader :result
    
    def initialize
      @configuration = Configuration.new
      @connection = @configuration.connect
    end

    def query(sql)
      @result = @connection.query(sql)
      self
    end

    def execute_task(task)
      @result = @connection.query(@configuration.tasks[task.to_s])
      self
    end

    def print(header=true)
      Printer.new(@result, header).print
    end

    def command
      @configuration.to_hash.inject(["mysql"]) do |c,(k,v)|
        case k
        when :host then c << "-h#{v}"
        when :port then c << "-P#{v}"
        when :username then c << "-u#{v}"
        when :password then c << "-p#{v}"
        when :database then c << v
        end
      end.join(" ")
    end

    class << self
      def method_missing(action, *args)
        client = self.new
        if client.respond_to? action
          client.send(action, *args)
        else
          super
        end
      end
    end
  end
end
