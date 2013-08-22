require "spec_helper"

describe Mycmd::SettingsCommands do
  describe "#search" do
    it "should print result" do
      mock = double("connection mock")
      mock.should_receive(:query).and_return(create_result)
      Mycmd::Configuration.should_receive(:connect).and_return(mock)
      expect(
        capture(:stdout) {
          Mycmd::SettingsCommands.start(["search", "param_name"])
        }
      ).not_to be_nil
    end

    it "should call Configuration.connect" do
      mock = double("connection mock")
      mock.should_receive(:query).and_return(create_result)
      Mycmd::Configuration.should_receive(:connect).and_return(mock)
      Mycmd::Printer.any_instance.stub(:print)
      expect {
        Mycmd::SettingsCommands.start(["search", "param_name"])
      }.not_to raise_error
    end

    it "should call Printer#print" do
      mock = double("connection mock")
      mock.should_receive(:query).and_return(create_result)
      Mycmd::Configuration.stub(:connect).and_return(mock)
      Mycmd::Printer.any_instance.should_receive(:print)
      expect {
        Mycmd::SettingsCommands.start(["search", "param_name"])
      }.not_to raise_error
    end
  end
end