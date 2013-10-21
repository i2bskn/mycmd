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
        }.chomp
      ).to eq("config not found")
    end

    it "should print config path" do
      config = "/Users/i2bskn/.mycmd.yml"
      Mycmd::Configuration.stub(:config_find).and_return(config)
      expect(
        capture(:stdout){
          Mycmd::ConfigCommands.start(args)
        }.chomp
      ).to eq(config)
    end
  end

  describe "#cat" do
    let(:args) {["cat"]}

    it "should call Configuration.config_find" do
      Mycmd::Configuration.should_receive(:config_find).and_return(".mycmd.yml")
      File.stub(:open).and_return([])
      Mycmd::ConfigCommands.start(args)
    end

    it "should print error message if file not found" do
      Mycmd::Configuration.stub(:config_find).and_return(nil)
      expect(
        capture(:stdout){
          Mycmd::ConfigCommands.start(args)
        }.chomp
      ).to eq("config not found")
    end
  end

  describe "#edit" do
    let(:args) {["edit"]}

    it "should call Configuration.config_find" do
      Mycmd::Configuration.should_receive(:config_find).and_return(".mycmd.yml")
      Kernel.stub(:system)
      Mycmd::ConfigCommands.start(args)
    end

    it "should execute edit command" do
      Mycmd::Configuration.stub(:config_find).and_return(".mycmd.yml")
      Kernel.should_receive(:system).with("#{ENV['EDITOR']} .mycmd.yml")
      Mycmd::ConfigCommands.start(args)
    end

    it "should print error message if file not found" do
      Mycmd::Configuration.stub(:config_find).and_return(nil)
      expect(
        capture(:stdout){
          Mycmd::ConfigCommands.start(args)
        }.chomp
      ).to eq("config not found")
    end
  end
end