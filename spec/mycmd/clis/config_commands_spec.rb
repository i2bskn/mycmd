require "spec_helper"

describe Mycmd::ConfigCommands do
  describe "#which" do
    let(:args) {["which"]}

    it "should call Configuration.config_find" do
      Mycmd::Configuration.should_receive(:config_find).and_return(nil)
      expect(
        capture(:stdout){
          Mycmd::ConfigCommands.start(args)
        }
      ).not_to be_nil
    end

    it "should print not found message if file not found" do
      Mycmd::Configuration.stub(:config_find).and_return(nil)
      expect(
        capture(:stdout){
          Mycmd::ConfigCommands.start(args)
        }
      ).to eq("config not found\n")
    end

    it "should print config path" do
      config = "/Users/i2bskn/.mycmd.yml"
      Mycmd::Configuration.stub(:config_find).and_return(config)
      expect(
        capture(:stdout){
          Mycmd::ConfigCommands.start(args)
        }
      ).to eq("#{config}\n")
    end
  end

  describe "#edit" do
    let(:args) {["edit"]}

    it "should execute edit command" do
      Mycmd::Configuration.stub(:config_find).and_return(".mycmd.yml")
      Kernel.should_receive(:system).with("#{ENV['EDITOR']} .mycmd.yml")
      Mycmd::ConfigCommands.start(args)
    end

    it "should generate exception if file not found" do
      Mycmd::Configuration.stub(:config_find).and_return(nil)
      expect {
        Mycmd::ConfigCommands.start(args)
      }.to raise_error(RuntimeError)
    end

    it "should call Configuration.config_find" do
      Mycmd::Configuration.should_receive(:config_find).and_return(".mycmd.yml")
      Kernel.stub(:system)
      Mycmd::ConfigCommands.start(args)
    end
  end

  describe "#cat" do
    let(:args) {["cat"]}

    it "should call Configuration.config_find" do
      Mycmd::Configuration.should_receive(:config_find).and_return(".mycmd.yml")
      File.stub(:open).and_return([])
      Mycmd::ConfigCommands.start(args)
    end

    it "should generate exception if file not found" do
      Mycmd::Configuration.stub(:config_find).and_return(nil)
      expect {
        Mycmd::ConfigCommands.start(args)
      }.to raise_error(RuntimeError)
    end
  end
end