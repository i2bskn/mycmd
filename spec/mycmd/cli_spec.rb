require "spec_helper"

describe Mycmd::CLI do
  let(:conn_mock) {double("connection mock").as_null_object}
  let(:printer_mock) {double("printer mock").as_null_object}

  describe "#console" do
    let(:args) {["console"]}

    before do
      Mycmd::Configuration.stub(:config_find).and_return(nil)
    end

    it "should call Kernel.system" do
      conf = Mycmd::Configuration.new
      conf.password = "secret"
      conf.database = "test"
      Mycmd::Configuration.should_receive(:new).and_return(conf)
      Kernel.should_receive(:system).exactly(2).and_return(true)
      expect {
        Mycmd::CLI.start(args)
      }.not_to raise_error
    end

    it "should generate exception if mysql command not found" do
      Kernel.should_receive(:system).and_return(false)
      expect {
        Mycmd::CLI.start(args)
      }.to raise_error
    end
  end

  describe "#query" do
    before do
      Mycmd::Configuration.stub(:connect).and_return(conn_mock)
      Mycmd::Printer.stub(:new).and_return(printer_mock)
    end

    after do
      expect {
        Mycmd::CLI.start(["query", "some sql"])
      }.not_to raise_error
    end

    it "should call Configuration.connect" do
      Mycmd::Configuration.should_receive(:connect).and_return(conn_mock)
    end

    it "should create Printer object" do
      Mycmd::Printer.should_receive(:new).with(conn_mock, true).and_return(printer_mock)
    end

    it "should call Printer#print" do
      printer_mock.should_receive(:print)
    end
  end

  describe "#tasks" do
    let(:config_mock) {double("configuration mock").as_null_object}

    before do
      config_mock.stub(:connect).and_return(conn_mock)
      Mycmd::Configuration.stub(:new).and_return(config_mock)
      Mycmd::Printer.stub(:new).and_return(printer_mock)
    end

    after do
      expect {
        Mycmd::CLI.start(["tasks", "some task"])
      }.not_to raise_error
    end

    it "should create Configuration object" do
      Mycmd::Configuration.should_receive(:new).and_return(config_mock)
    end

    it "should call Configuration#connect" do
      config_mock.should_receive(:connect).and_return(conn_mock)
    end

    it "should create Printer object" do
      Mycmd::Printer.should_receive(:new).with(conn_mock, true).and_return(printer_mock)
    end

    it "should call Printer#print" do
      printer_mock.should_receive(:print)
    end
  end
end
