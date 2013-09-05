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
  end
end
