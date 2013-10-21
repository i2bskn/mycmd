require "spec_helper"

describe Mycmd::StatusCommands do
  let(:conn_mock) {double("connection mock")}
  let(:client) {create_configuration_mock}

  describe "#size" do
    context "with not arguments" do
      let(:args) {["size"]}
      let(:sql) {"SELECT T.TABLE_SCHEMA, CAST((SUM(T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) AS SIZE_MB FROM INFORMATION_SCHEMA.TABLES AS T GROUP BY T.TABLE_SCHEMA UNION SELECT 'all_databases', CAST((SUM(T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) FROM INFORMATION_SCHEMA.TABLES AS T"}

      context "without failed" do
        after {Mycmd::StatusCommands.start(args)}

        it "should call Mycmd::Client.#query" do
          Mycmd::Client.should_receive(:query).with(sql).and_return(client)
        end

        it "should call Mycmd::Client#print" do
          client.should_receive(:print)
          Mycmd::Client.stub(:query).and_return(client)
        end
      end

      context "with failed" do
        it "should display error message" do
          Mycmd::Client.should_receive(:query).with(sql).and_raise("test")
          expect(
            capture(:stdout){
              Mycmd::StatusCommands.start(args)
            }.chomp
          ).to eq("test")
        end
      end
    end

    context "with arguments" do
      let(:args) {["size", "-d", "some_db"]}
      let(:sql) {"SELECT T.TABLE_NAME, CAST(((T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) AS SIZE_MB FROM INFORMATION_SCHEMA.TABLES AS T WHERE T.TABLE_SCHEMA = 'some_db' UNION SELECT 'all_tables', CAST((SUM(T.DATA_LENGTH+T.INDEX_LENGTH)/1024/1024) AS CHAR) FROM INFORMATION_SCHEMA.TABLES AS T WHERE T.TABLE_SCHEMA = 'some_db'"}

      context "without failed" do
        after {Mycmd::StatusCommands.start(args)}

        it "should call Mycmd::Client.#query" do
          Mycmd::Client.should_receive(:query).with(sql).and_return(client)
        end

        it "should call Mycmd::Client#print" do
          client.should_receive(:print)
          Mycmd::Client.stub(:query).and_return(client)
        end
      end

      context "with failed" do
        it "should display error message" do
          Mycmd::Client.should_receive(:query).with(sql).and_raise("test")
          expect(
            capture(:stdout){
              Mycmd::StatusCommands.start(args)
            }.chomp
          ).to eq("test")
        end
      end
    end
  end

  describe "#qcache_hit_rate" do
    let(:args) {["qcache_hit_rate"]}

    context "with qcache enabled" do
      let(:sql) {"SELECT (SELECT (SELECT G.VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME = 'QCACHE_HITS')/(SELECT SUM(G.VARIABLE_VALUE) FROM INFORMATION_SCHEMA.GLOBAL_STATUS AS G WHERE G.VARIABLE_NAME IN ('QCACHE_HITS','QCACHE_INSERTS','QCACHE_NOT_CACHED')) * 100) AS rate"}

      before do
        Mycmd::Client.stub(:query).with("SELECT G.VARIABLE_VALUE AS size FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES AS G WHERE G.VARIABLE_NAME = 'QUERY_CACHE_SIZE'").and_return(double("Mycmd::Client Mock", result: [{"size" => "4000"}]))
        Mycmd::Client.stub(:query).with(sql).and_return(client)
      end

      it "should call Client.#query" do
        client.stub(:result).and_return([{"rate" => 20}])
        Mycmd::Client.should_receive(:query).with(sql).and_return(client)
        capture(:stdout) {
          Mycmd::StatusCommands.start(args)
        }
      end

      it "should output the query cache hit rate" do
        client.stub(:result).and_return([{"rate" => 20}])
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("\e[32m20 %\e[m")
      end

      it "should output red color of char if rate is unknown" do
        client.stub(:result).and_return(nil)
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("\e[31munknown\e[m")
      end

      it "should output red color of char if rate < 20" do
        client.stub(:result).and_return([{"rate" => 10}])
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("\e[31m10 %\e[m")
      end

      it "should output green color of char if rate >= 20" do
        client.stub(:result).and_return([{"rate" => 20}])
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("\e[32m20 %\e[m")
      end
    end

    context "with qcache disabled" do
      it "should display error message" do
        Mycmd::Client.stub(:query).with("SELECT G.VARIABLE_VALUE AS size FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES AS G WHERE G.VARIABLE_NAME = 'QUERY_CACHE_SIZE'").and_return(double("Mycmd::Client Mock", result: [{"size" => "0"}]))
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("Query cache is disabled.")
      end
    end
  end

  describe "#innodb_buffer_hit_rate" do
    let(:args) {["innodb_buffer_hit_rate"]}

    context "without failed" do
      before {Mycmd::Client.stub(:query).and_return(client)}

      it "should call Client.#query" do
        client.should_receive(:result).and_return([{"rate" => 95}])
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).not_to be_nil
      end

      it "should output the innodb buffer hit rate" do
        client.stub(:result).and_return([{"rate" => 95}])
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("\e[32m95 %\e[m")
      end

      it "should output red color of char if rate is unknown" do
        client.stub(:result).and_return(nil)
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("\e[31munknown\e[m")
      end

      it "should output red color of char if rate < 90" do
        client.stub(:result).and_return([{"rate" => 85}])
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("\e[31m85 %\e[m")
      end

      it "should output green color of char if rate >= 90" do
        client.stub(:result).and_return([{"rate" => 95}])
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("\e[32m95 %\e[m")
      end
    end

    context "with failed" do
      it "should display error message" do
        Mycmd::Client.should_receive(:query).and_raise("test")
        expect(
          capture(:stdout) {
            Mycmd::StatusCommands.start(args)
          }.chomp
        ).to eq("test")
      end
    end
  end
end
