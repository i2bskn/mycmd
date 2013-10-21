# coding: utf-8

module Mycmd
  class StatusCommands < Thor
    namespace :status

    desc "size", "size will print database/table size"
    option :database, aliases: "-d", desc: "target database."
    def size
      begin
        sql = options["database"].nil? ? SQL::ALL_DATABASE_SIZES : SQL.table_sizes(options['database'])      
        Client.query(sql).print
      rescue => e
        puts e.message
      end
    end

    desc "qcache_hit_rate", "qcache_hit_rate will print query cache hit rate"
    def qcache_hit_rate
      begin
        raise "Query cache is disabled." if Client.query(SQL::QCACHE_SIZE).result.first["size"] == "0"
        print_rate(Client.query(SQL::QCACHE_HIT_RATE).result, 20)
      rescue => e
        puts e.message
      end
    end

    desc "innodb_buffer_hit_rate", "innodb_buffer_hit_rate will print buffer hit rate"
    def innodb_buffer_hit_rate
      begin
        print_rate(Client.query(SQL::INNODB_BUFFER_HIT_RATE).result, 90)
      rescue => e
        puts e.message
      end
    end

    private
    def print_rate(rate, threshold)
      if rate.nil?
        rate = "\e[31munknown\e[m"
      else
        rate = rate.first["rate"].to_i
        rate = rate >= threshold ? "\e[32m#{rate} %\e[m" : "\e[31m#{rate} %\e[m"
      end
      puts rate
    end
  end
end
