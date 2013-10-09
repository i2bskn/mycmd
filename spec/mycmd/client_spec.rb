require "spec_helper"

describe Mycmd::Client do
  let(:client) {Mycmd::Client.new}
  let(:connection) {double("Mysql2::Client Mock").as_null_object}
  let(:config) {double("Mycmd::Configuration Mock").as_null_object}

  describe "#initialize" do
    it "should generate Configuration object" do
      Mycmd::Configuration.should_receive(:new).and_return(config)
      Mycmd::Client.new
    end

    it "should call Configuration#connect" do
      config.should_receive(:connect)
      Mycmd::Configuration.should_receive(:new).and_return(config)
      Mycmd::Client.new
    end
  end

  describe "#query" do
    before do
      config.stub(:connect).and_return(connection)
      Mycmd::Configuration.stub(:new).and_return(config)
    end

    it "should call Mysql2::Client#query" do
      connection.should_receive(:query)
      client.query("some sql")
    end

    it "should set result" do
      connection.should_receive(:query).and_return("result")
      client.query("some sql")
      expect(client.instance_eval{@result}).not_to be_nil
    end

    it "returns Mycmd::Client object" do
      expect(client.query("some sql").is_a? Mycmd::Client).to be_true
    end
  end

  describe "#execute_task" do
    before do
      config.stub(:connect).and_return(connection)
      Mycmd::Configuration.stub(:new).and_return(config)
    end

    it "should call Mysql2::Client#query" do
      connection.should_receive(:query)
      client.execute_task("some_task")
    end

    it "should set result" do
      connection.should_receive(:query).and_return("result")
      client.execute_task("some_task")
      expect(client.instance_eval{@result}).not_to be_nil
    end

    it "returns Mycmd::Client object" do
      expect(client.execute_task("some_task").is_a? Mycmd::Client).to be_true
    end
  end

  describe "#print" do
    let(:printer) {double("Mycmd::Printer Mock").as_null_object}

    before do
      config.stub(:connect).and_return(connection)
      Mycmd::Configuration.stub(:new).and_return(config)
    end

    it "should create Mycmd::Printer object" do
      Mycmd::Printer.should_receive(:new).and_return(printer)
      client.print
    end

    it "should call Mycmd::Printer#print" do
      printer.should_receive(:print)
      Mycmd::Printer.stub(:new).and_return(printer)
      client.print
    end
  end

  describe ".#method_missing" do
    before do
      connection.stub(:query)
      config.stub(:connect).and_return(connection)
      Mycmd::Configuration.stub(:new).and_return(config)
    end

    context "with known method" do
      it "should call Mycmd::Client#query" do
        Mycmd::Client.any_instance.should_receive(:query)
        Mycmd::Client.query("some sql")
      end
    end

    context "with unknown method" do
      it "should generate exception" do
        expect {
          Mycmd::Client.unknown_method
        }.to raise_error
      end
    end
  end
end
