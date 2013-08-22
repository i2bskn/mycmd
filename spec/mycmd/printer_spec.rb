require "spec_helper"

describe Mycmd::Printer do
  class Result
    attr_reader :fields
    def initialize
      @data = [
        ["first", "one"],
        ["second", "two"],
        ["third", "three"]
      ]
      @fields = ["order", "number"]
    end
    def each(params={})
      @data.each do |d|
        yield(d)
      end
    end
  end

  let(:result) do
    Result.new
  end

  let(:printer) {Mycmd::Printer.new(result)}

  describe "#initialize" do
    it "should set specified result" do
      expect(printer.result).to eq(result)
    end

    it "should set default header flug" do
      expect(printer.header).to be_false
    end

    it "should set specified header flug" do
      printer = Mycmd::Printer.new(result, true)
      expect(printer.header).to be_true
    end
  end

  describe "#print" do
    it "should call #set_width" do
      printer.send(:set_width)
      Mycmd::Printer.any_instance.should_receive(:set_width)
      Mycmd::Printer.any_instance.stub(:print_line).and_return(nil)
      expect {
        printer.print
      }.not_to raise_error
    end

    it "should call #print_line" do
      Mycmd::Printer.any_instance.should_receive(:print_line).exactly(3)
      expect {
        printer.print
      }.not_to raise_error
    end

    it "should not call #print_line if each method not found" do
      Mycmd::Printer.any_instance.should_not_receive(:print_line)
      Result.any_instance.should_receive(:respond_to?).and_return(false)
      expect{
        printer.print
      }.not_to raise_error
    end
  end

  describe "#set_width" do
    it "should set max length" do
      printer.send(:set_width)
      expect(printer.width).to eq([6,6])
    end
  end

  describe "#print_line" do
    it "should print line" do
      expect(capture(:stdout){printer.print}).not_to be_nil
    end
  end
end
