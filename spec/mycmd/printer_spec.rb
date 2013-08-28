require "spec_helper"

describe Mycmd::Printer do
  let(:result) {create_result}
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

    it "should generate exception if not specified arguments" do
      expect {
        Mycmd::Printer.new
      }.to raise_error
    end
  end

  describe "#print" do
    after do
      expect {
        printer.print
      }.not_to raise_error
    end

    it "should call #set_width" do
      printer.send(:set_width)
      Mycmd::Printer.any_instance.should_receive(:set_width)
      Mycmd::Printer.any_instance.stub(:print_line).and_return(nil)
    end

    it "should call #print_line" do
      Mycmd::Printer.any_instance.should_receive(:print_line).exactly(3)
    end

    it "should not call #print_line if each method not found" do
      Mycmd::Printer.any_instance.should_not_receive(:print_line)
      result.should_receive(:respond_to?).and_return(false)
    end
  end

  describe "#result_to_array" do
    it "should convert to array from result" do
      expect(printer.send(:result_to_array, create_result)).to eq([
        ["first", "one"],
        ["second", "two"],
        ["third", "three"]
      ])
    end
  end

  describe "#set_width" do
    it "should set max length" do
      printer.send(:set_width)
      expect(printer.width).to eq([6,5])
    end

    it "should hoge" do
      printer.header = result.fields
      printer.send(:set_width)
      expect(printer.width).to eq([6,6])
    end
  end

  describe "#print_line" do
    it "should print line" do
      expect(capture(:stdout){printer.print}).not_to be_nil
    end
  end

  describe "#print_title" do
    it "should print title" do
      expect(capture(:stdout){Mycmd::Printer.print_title("title")}).not_to be_nil
    end

    it "should print empty line" do
      expect(capture(:stdout){Mycmd::Printer.print_title("title", true)}).to match(/^\n/)
    end
  end
end
