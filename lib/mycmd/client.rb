# coding: utf-8

module Mycmd
  class Client
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
