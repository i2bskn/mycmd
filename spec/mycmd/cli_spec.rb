require "spec_helper"

describe Mycmd::CLI do
  let(:client) {double("client mock").as_null_object}

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
    before {Mycmd::Client.stub(:query).and_return(client)}

    after do
      expect {
        Mycmd::CLI.start(["query", "some sql"])
      }.not_to raise_error
    end

    it "should call Client.#query" do
      Mycmd::Client.should_receive(:query).and_return(client)
    end

    it "should call Client#print" do
      client.should_receive(:print)
    end
  end

  describe "#tasks" do
    before {Mycmd::Client.stub(:execute_task).and_return(client)}

    after do
      expect {
        Mycmd::CLI.start(["tasks", "some_task"])
      }.not_to raise_error
    end

    it "should call Client.#execute_task" do
      Mycmd::Client.should_receive(:execute_task).and_return(client)
    end

    it "should call Client#print" do
      client.should_receive(:print)
    end
  end
end
