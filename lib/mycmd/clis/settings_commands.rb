# coding: utf-8

module Mycmd
  class SettingsCommands < Thor
    namespace :settings

    GLOBAL_BUFFERS = [
      :innodb_buffer_pool_size,
      :innodb_log_buffer_size,
      :innodb_additional_mem_pool_size,
      :key_buffer_size,
      :query_cache_size
    ].freeze

    THREAD_BUFFERS = [
      :sort_buffer_size,
      :read_buffer_size,
      :read_rnd_buffer_size,
      :join_buffer_size,
      :tmp_table_size,
      :max_heap_table_size,
      :net_buffer_length,
      :max_allowed_packet,
      :thread_stack
    ].freeze

    desc "search innodb_buffer_pool_size", "search will print settings"
    def search(keyword)
      client = Configuration.connect
      printer = Printer.new(client.query("SHOW GLOBAL VARIABLES LIKE '%#{keyword}%'"))
      printer.print
    end

    desc "memories", "memories will print memory settings"
    def memories
      variables = Configuration.get_variables
      global, gtotal = create_result_variables(GLOBAL_BUFFERS, variables)
      thread, ttotal = create_result_variables(THREAD_BUFFERS, variables)
      expected = expected_memory_used(gtotal, variables)
      Printer.print_title("GLOBAL BUFFERS")
      Printer.new(global).print
      Printer.print_title("THREAD BUFFERS", true)
      Printer.new(thread).print
      Printer.print_title("EXPECTED MEMORY USED", true)
      Printer.new(expected).print
    end

    private
    def create_result_variables(keys, variables)
      rows = []
      total = keys.inject(0) do |t,key|
        bytes = variables[key].to_i
        rows << [key.to_s ,"#{bytes} bytes (#{bytes.to_f/1024/1024} MB)"]
        t + bytes
      end
      return rows, total
    end

    def expected_memory_used(global, variables)
      max_connections = variables[:max_connections].to_i
      threads = expected_threads(variables, max_connections)
      total = global + threads
      [
        ["max_connections", "#{max_connections} connections"],
        ["expected memory use of global", "#{global} bytes (#{global.to_f/1024/1024} MB)"],
        ["expected memory use of threads", "#{threads} bytes (#{threads.to_f/1024/1024} MB)"],
        ["expected total", "#{total} bytes (#{total.to_f/1024/1024} MB)"]
      ]
    end

    def expected_threads(variables, max_connections)
      base = variables[:net_buffer_length].to_i + variables[:thread_stack].to_i
      tmp = variables[:tmp_table_size].to_i * 0.1
      buffer = THREAD_BUFFERS[0..3].inject(0){|b,k| b + (variables[k].to_i * 0.5)}
      ((base + tmp + buffer) * max_connections)
    end
  end
end
