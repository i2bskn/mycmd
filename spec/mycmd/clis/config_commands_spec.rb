require "spec_helper"

describe Mycmd::ConfigCommands do
  describe "#which" do
    it "should call Configuration.config_find" do
      Mycmd::Configuration.should_receive(:config_find).and_return(nil)
      expect(
        capture(:stdout){
          Mycmd::ConfigCommands.start(["which"])
        }
      ).not_to be_nil
    end

    it "should print not found message if file not found" do
      Mycmd::Configuration.stub(:config_find).and_return(nil)
      expect(
        capture(:stdout){
          Mycmd::ConfigCommands.start(["which"])
        }
      ).to eq("config not found\n")
    end

    it "should print config path" do
      config = "/Users/i2bskn/.mycmd.yml"
      Mycmd::Configuration.stub(:config_find).and_return(config)
      expect(
        capture(:stdout){
          Mycmd::ConfigCommands.start(["which"])
        }
      ).to eq("#{config}\n")
    end
  end

  describe "#edit" do
    it "should execute edit command" do
      Mycmd::Configuration.stub(:config_find).and_return(".mycmd.yml")
      Mycmd::ConfigCommands.any_instance.should_receive(:system)
      Mycmd::ConfigCommands.start(["edit"])
    end

    it "should generate exception if file not found" do
      Mycmd::Configuration.stub(:config_find).and_return(nil)
      expect {
        Mycmd::ConfigCommands.start(["edit"])
      }.to raise_error(RuntimeError)
    end

    it "should call Configuration.config_find" do
      Mycmd::Configuration.should_receive(:config_find).and_return(".mycmd.yml")
      Mycmd::ConfigCommands.any_instance.stub(:system)
      Mycmd::ConfigCommands.start(["edit"])
    end
  end

  describe "#cat" do
    it "should call Configuration.config_find" do
      Mycmd::Configuration.should_receive(:config_find).and_return(".mycmd.yml")
      Mycmd::ConfigCommands.any_instance.stub(:open).and_return([])
      Mycmd::ConfigCommands.start(["cat"])
    end

    it "should generate exception if file not found" do
      Mycmd::Configuration.stub(:config_find).and_return(nil)
      expect {
        Mycmd::ConfigCommands.start(["cat"])
      }.to raise_error(RuntimeError)
    end
  end
end