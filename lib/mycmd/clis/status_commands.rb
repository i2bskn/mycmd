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
      client = Configuration.connect
      printer = Printer.new(client.query(sql), true)
      printer.print
    end

    desc "qcache_hit_rate", "qcache_hit_rate will print query cache hit rate"
    def qcache_hit_rate
      client = Configuration.connect
      rate = client.query("SELECT IFNULL((SELECT (SELECT G.VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME = 'QCACHE_HITS')/(SELECT SUM(G.VARIABLE_VALUE) FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME IN ('QCACHE_HITS','QCACHE_INSERTS','QCACHE_NOT_CACHED')) * 100), 0) AS qcache_hit_rate")
      puts "#{rate.first['qcache_hit_rate']} %"
    end
  end
end
