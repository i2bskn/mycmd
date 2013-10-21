require "spec_helper"

describe Mycmd::SettingsCommands do
  describe "#search" do
    let(:args) {["search", "param_name"]}
    let(:conn_mock) {double("connection mock")}

    before do
      conn_mock.stub(:query).and_return(create_result)
      Mycmd::Configuration.stub(:connect).and_return(conn_mock)
    end

    after do
      expect(capture(:stdout){Mycmd::SettingsCommands.start(args)}).not_to be_nil
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
    before {Mycmd::Configuration.stub(:get_variables).and_return(create_variables)}

    after do
      expect(capture(:stdout){Mycmd::SettingsCommands.start(args)}).not_to be_nil
    end

    it "should call Configuration.#get_variables" do
      Mycmd::Configuration.should_receive(:get_variables).and_return(create_variables)
    end

    it "should call SettingsCommands#create_result_variables" do
      Mycmd::Printer.stub(:new).and_return(double.as_null_object)
      Mycmd::SettingsCommands.any_instance.should_receive(:create_result_variables).exactly(2).and_return([["key", "varue"], 310378496])
    end

    it "should call SettingsCommands#expected_memory_used" do
      Mycmd::Printer.stub(:new).and_return(double.as_null_object)
      Mycmd::SettingsCommands.any_instance.should_receive(:expected_memory_used).and_return([["key", "varue"], ["key", "value"]])
    end

    it "should call Printer.#print_title" do
      Mycmd::Printer.should_receive(:print_title).exactly(3)
    end

    it "should create Printer object" do
      Mycmd::Printer.should_receive(:new).exactly(3).and_return(double.as_null_object)
    end
  end
end