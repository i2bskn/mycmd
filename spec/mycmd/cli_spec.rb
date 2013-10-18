require "spec_helper"

describe Mycmd::CLI do
  let(:client) {double("client mock").as_null_object}

  describe "#console" do
    let(:args) {["console"]}
    before {Mycmd::Client.stub(:command)}

    it "should call Kernel.system" do
      Kernel.should_receive(:system).exactly(2).and_return(true)
      expect {
        Mycmd::CLI.start(args)
      }.not_to raise_error
    end

    it "should print message if mysql command not found" do
      Kernel.should_receive(:system).with("which mysql > /dev/null").exactly(1).and_return(false)
      expect(
        capture(:stdout){
          Mycmd::CLI.start(args)
        }.chomp
      ).to eq("mysql command not found")
    end
  end

  describe "#query" do
    let(:args) {["query", "some sql"]}

    context "with execution of sql is successfull" do
      after do
        expect {
          Mycmd::CLI.start(args)
        }.not_to raise_error
      end

      it "should call Client.#query" do
        Mycmd::Client.should_receive(:query).and_return(client)
      end

      it "should call Client#print" do
        client.should_receive(:print)
        Mycmd::Client.stub(:query).and_return(client)
      end
    end

    context "with execution of sql is failed" do
      it "should print error message" do
        Mycmd::Client.should_receive(:query).and_raise("some error")
        expect(
          capture(:stdout){
            Mycmd::CLI.start(args)
          }.chomp
        ).to eq("some error")
      end
    end
  end

  describe "#tasks" do
    context "without list option" do
      let(:args) {["tasks", "some_task"]}

      context "with execution of task is successfull" do
        after do
          expect {
            Mycmd::CLI.start(args)
          }.not_to raise_error
        end

        it "should call Client.#execute_task" do
          Mycmd::Client.should_receive(:execute_task).and_return(client)
        end

        it "should call Client#print" do
          client.should_receive(:print)
          Mycmd::Client.stub(:execute_task).and_return(client)
        end
      end

      context "with execution of task is failed" do
        it "should print error message" do
          Mycmd::Client.should_receive(:execute_task).and_raise("some error")
          expect(
            capture(:stdout){
              Mycmd::CLI.start(args)
            }.chomp
          ).to eq("some error")
        end
      end
    end

    context "with list option" do
      let(:configuration) {create_configuration_mock}
      let(:args) {["tasks", "-l"]}

      before {Mycmd::Configuration.should_receive(:new).and_return(configuration)}

      it "should print message if tasks is not registered" do
        configuration.should_receive(:tasks).and_return(nil)
        expect(
          capture(:stdout){
            Mycmd::CLI.start(args)
          }.chomp
        ).to eq("task is not registered")
      end

      it "should print tasks" do
        configuration.stub(:tasks).and_return({"key" => "value"})
        expect(
          capture(:stdout){
            Mycmd::CLI.start(args)
          }.chomp
        ).to eq("key:\tvalue")
      end
    end
  end
end
