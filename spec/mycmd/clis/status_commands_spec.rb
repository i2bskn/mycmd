require "spec_helper"

describe Mycmd::StatusCommands do
  let(:conn_mock) {double("connection mock")}

  describe "#size" do
    let(:ptr_mock) {double("printer mock").as_null_object}

    before do
      conn_mock.stub(:query).and_return(create_result)
      Mycmd::Configuration.stub(:connect).and_return(conn_mock)
      Mycmd::Printer.stub(:new).and_return(ptr_mock)
    end

    context "with not arguments" do
      let(:args) {["size"]}
      after {Mycmd::StatusCommands.start(args)}

      it "should call Configuration.#connect" do
        Mycmd::Configuration.should_receive(:connect).and_return(conn_mock)
      end

      it "should create Printer object" do
        Mycmd::Printer.should_receive(:new).and_return(ptr_mock)
      end

      it "should call Printer#print" do
        ptr_mock.should_receive(:print)
      end

      it "should output the size of all databases" do
        conn_mock.should_receive(:query).with("SELECT T.TABLE_SCHEMA, CAST((SUM(T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) AS SIZE_MB FROM INFORMATION_SCHEMA.TABLES AS T GROUP BY T.TABLE_SCHEMA UNION SELECT 'all_databases', CAST((SUM(T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) FROM INFORMATION_SCHEMA.TABLES AS T")
      end
    end

    it "should output the size of all tables" do
      conn_mock.should_receive(:query).with("SELECT T.TABLE_NAME, CAST(((T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) AS SIZE_MB FROM INFORMATION_SCHEMA.TABLES AS T WHERE T.TABLE_SCHEMA = 'some_db' UNION SELECT 'all_tables', CAST((SUM(T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) FROM INFORMATION_SCHEMA.TABLES AS T WHERE T.TABLE_SCHEMA = 'some_db'")
      Mycmd::StatusCommands.start(["size", "-d", "some_db"])
    end
  end

  describe "#qcache_hit_rate" do
    let(:args) {["qcache_hit_rate"]}

    before do
      conn_mock.stub(:query).and_return(double.as_null_object)
      Mycmd::Configuration.stub(:connect).and_return(conn_mock)
    end

    after do
      expect(capture(:stdout){Mycmd::StatusCommands.start(args)}).not_to be_nil
    end

    it "should call Configuration.#connect" do
      Mycmd::Configuration.should_receive(:connect).and_return(conn_mock)
    end

    it "should output the hit rate of query cache" do
      conn_mock.should_receive(:query).with("SELECT IFNULL((SELECT (SELECT G.VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME = 'QCACHE_HITS')/(SELECT SUM(G.VARIABLE_VALUE) FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME IN ('QCACHE_HITS','QCACHE_INSERTS','QCACHE_NOT_CACHED')) * 100), 0) AS qcache_hit_rate").and_return(double.as_null_object)
    end
  end
end
