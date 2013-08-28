require "spec_helper"

describe Mycmd::SettingsCommands do
  describe "#search" do
    let(:args) {["search", "param_name"]}
    let(:conn_mock) do
      mock = double("connection mock")
      mock.stub(:query).and_return(create_result)
      mock
    end

    before {Mycmd::Configuration.stub(:connect).and_return(conn_mock)}

    after do
      expect(
        capture(:stdout) {
          Mycmd::SettingsCommands.start(args)
        }
      ).not_to be_nil
    end

    it "should call Configuration.connect" do
      Mycmd::Configuration.should_receive(:connect).and_return(conn_mock)
    end

    it "should create Printer object" do
      Mycmd::Printer.should_receive(:new).and_return(double.as_null_object)
    end

    it "should call Printer#print" do
      Mycmd::Printer.any_instance.should_receive(:print)
    end
  end

  describe "#memories" do
    let(:args){["memories"]}

    it "returns expected threads" do
      Mycmd::Configuration.stub(:get_variables).and_return(create_variables)
      expect(
        capture(:stdout) {
          Mycmd::SettingsCommands.start(args)
        }
      ).not_to be_nil
    end
  end
end