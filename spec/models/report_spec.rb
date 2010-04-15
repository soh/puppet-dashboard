require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  describe "#metrics" do
    it "should not fail when there are no metrics" do
      @report = Report.new
      @report.stubs(:report).returns(mock(:metrics => nil))
      lambda{@report.metrics}.should_not raise_error
    end
  end

  describe "on creation" do
    before do
      @now = Time.now
      Time.stubs(:now).returns(@now)
      @node = Node.generate
      @report_yaml ="--- !ruby/object:Puppet::Transaction::Report \nhost: localhost\nlogs: []\n\nmetrics: {}\n\nrecords: {}\n\ntime: 2009-12-17 14:18:13.225235 -08:00\n"
      @report_data = YAML.load @report_yaml
    end

    it "is not created if a report for the same host exists with the same time" do
      Report.create(:report => @report_yaml)
      lambda {
        Report.create(:report => @report_yaml)
      }.should_not change(Report, :count)
    end

    it "finds a node by host if it exists" do
      Node.expects(:find_or_create_by_name).with('localhost').returns(@node)
      Report.create(:report => @report_yaml)
    end

    it "creates a node by host if none exists" do
      lambda {
        Report.create(:report => @report_yaml)
      }.should change { Node.count(:conditions => {:name => 'localhost'}) }.by(1)
    end

    it "assigns the node to the report" do
      Node.expects(:find_or_create_by_name).with('localhost').returns(@node)
      Report.create(:report => @report_yaml).node.should == @node
    end

    it "updates the node's reported_at timestamp" do
      Node.expects(:find_or_create_by_name).with('localhost').returns(@node)
      lambda {
        Report.create(:report => @report_yaml)
      }.should change { @node.reported_at }.to(@report_data.time)
    end
  end

  describe "deserializing the report" do
    before do
      yaml_file = File.join RAILS_ROOT, "spec", "fixtures", "sample_report.yml"
      @loading_yaml = proc { YAML.load_file(yaml_file) }
    end

    it "should be able to parse the report" do
      @loading_yaml.should_not raise_error
    end

    it "should return a puppet report object" do
      @loading_yaml.call.should be_a_kind_of Puppet::Transaction::Report
    end

    it "should have the correct time" do
      @loading_yaml.call.time.to_yaml.should == "--- 2009-11-19 17:08:50.631428 -08:00\ntt"
    end
  end
end
