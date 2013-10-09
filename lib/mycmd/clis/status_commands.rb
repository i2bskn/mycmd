# coding: utf-8

module Mycmd
  class StatusCommands < Thor
    namespace :status

    desc "size", "size will print database/table size"
    option :database, aliases: "-d", desc: "target database."
    def size
      if options["database"].nil?
        sql = "SELECT T.TABLE_SCHEMA, CAST((SUM(T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) AS SIZE_MB FROM INFORMATION_SCHEMA.TABLES AS T GROUP BY T.TABLE_SCHEMA UNION SELECT 'all_databases', CAST((SUM(T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) FROM INFORMATION_SCHEMA.TABLES AS T"
      else
        sql = "SELECT T.TABLE_NAME, CAST(((T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) AS SIZE_MB FROM INFORMATION_SCHEMA.TABLES AS T WHERE T.TABLE_SCHEMA = '#{options['database']}' UNION SELECT 'all_tables', CAST((SUM(T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) FROM INFORMATION_SCHEMA.TABLES AS T WHERE T.TABLE_SCHEMA = '#{options['database']}'"
      end
      Client.query(sql).print
    end

    desc "qcache_hit_rate", "qcache_hit_rate will print query cache hit rate"
    def qcache_hit_rate
      client = Configuration.connect
      rate = client.query("SELECT (SELECT (SELECT G.VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME = 'QCACHE_HITS')/(SELECT SUM(G.VARIABLE_VALUE) FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME IN ('QCACHE_HITS','QCACHE_INSERTS','QCACHE_NOT_CACHED')) * 100) AS rate")
      print_rate(rate, 20)
    end

    desc "innodb_buffer_hit_rate", "innodb_buffer_hit_rate will print buffer hit rate"
    def innodb_buffer_hit_rate
      client = Configuration.connect
      rate = client.query("SELECT (1 - ((SELECT G.VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME = 'INNODB_BUFFER_POOL_READS')/(SELECT G.VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME = 'INNODB_BUFFER_POOL_READ_REQUESTS'))) * 100 AS rate")
      print_rate(rate, 90)
    end

    private
    def print_rate(rate, threshold)
      if rate.nil?
        rate = "\e[31munknown\e[m"
      else
        rate = rate.first["rate"]
        rate = rate >= threshold ? "\e[32m#{rate} %\e[m" : "\e[31m#{rate} %\e[m"
      end
      puts rate
    end
  end
end
