require 'spec_helper'

module Diaclone
  describe Result do
    let(:fixture) do
      {
        body: "Body.",
        lines: ["test"],
        hash: { test_attr: "test value" }
      }
    end

    subject { Result.new fixture }

    it "starts with an untouched body" do
      subject.body.should == "Body."
    end

    it "optionally preloads other attributes" do
      subject.body.should == "Body."
      subject.lines.first.should == "test"
      subject.hash.keys.first.should == :test_attr
      subject.hash[subject.hash.keys.first].should == "test value"
    end

    it "aliases brackets to hash when a symbol is used as a key" do
      subject[:test_attr].should == subject.hash[:test_attr]
    end

    it "aliases brackets to array when a number is used as a key" do
      subject.lines.first.should == subject[0]
    end

    it "acts like a hash in most circumstances" do
      subject.keys.should == subject.hash.keys
      subject.delete(:test_attr).should == "test value"
    end

    it "always keeps the body in a reader called `raw`" do
      subject.raw.should == subject.body
    end

    it "separates each key/value pair by newline when called as string" do
      subject.hash.merge! line_2: "value 2"
      subject.to_s.should == "test_attr: test value\nline_2: value 2"
    end
  end
end
