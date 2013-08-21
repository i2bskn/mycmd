require "spec_helper"

describe Mycmd::Configuration do
  let(:home_dir) {"/Users/i2bskn"}
  let(:conf_file) {File.join(home_dir, ".mycmd.yml")}
  let(:config) do
    Mycmd::Configuration.any_instance.stub(:reset).and_return(true)
    Mycmd::Configuration.new
  end

  describe "#initialize" do
    it "should call #reset" do
      Mycmd::Configuration.any_instance.should_receive(:reset)
      expect{
        Mycmd::Configuration.new
      }.not_to raise_error
    end
  end

  describe "#merge" do
    it "should call #default" do
      Mycmd::Configuration.any_instance.should_receive(:default)
      config.merge(host: "localhost")
    end

    it "should set specified params" do
      config.merge(host: "somehost")
      expect(config.host).to eq("somehost")
    end

    it "should generate exception if unknown params" do
      expect {
        config.merge(unknown: "unknown")
      }.to raise_error
    end
  end

  describe "#to_hash" do
    it "returns config hash" do
      config.default
      expect(config.to_hash.is_a? Hash).to be_true
    end
  end

  describe "#connect" do
    before {Mysql2::Client.should_receive(:new)}

    it "should create Mysql2::Client object" do
      expect {
        config.connect
      }.not_to raise_error
    end
  end

  describe "#reset" do
    it "should load yaml file" do
      Mycmd::Configuration.should_receive(:config_find).and_return(conf_file)
      Mycmd::Configuration.any_instance.should_receive(:merge)
      YAML.should_receive(:load_file).with(conf_file)
      expect {
        Mycmd::Configuration.new
      }.not_to raise_error
    end

    it "should call #default if config not found" do
      Mycmd::Configuration.should_receive(:config_find).and_return(nil)
      Mycmd::Configuration.any_instance.should_receive(:default)
      expect {
        Mycmd::Configuration.new
      }.not_to raise_error
    end
  end

  describe "#default" do
    before {config.default}

    it "should set default value to host" do
      expect(config.host).to eq("localhost")
    end

    it "should set default value to port" do
      expect(config.port).to eq(3306)
    end

    it "should set default value to username" do
      expect(config.username).to eq("root")
    end
  end

  describe ".connect" do
    it "should call #connect" do
      mock = double("configuration mock")
      mock.should_receive(:connect)
      Mycmd::Configuration.should_receive(:new).and_return(mock)
      expect {
        Mycmd::Configuration.connect
      }.not_to raise_error
    end
  end

  describe ".config_find" do
    let(:path) {Mycmd::Configuration.config_find(home_dir)}

    it "returns config path" do
      File.should_receive(:exists?).and_return(true)
      expect(path).to eq(conf_file)
    end

    it "returns nil if config not found" do
      File.should_receive(:exists?).at_least(2).and_return(false)
      expect(path).to be_nil
    end
  end
end