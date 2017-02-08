# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/denormalize"
#require "logstash/timestamp"

describe LogStash::Filters::Denormalize do

  context "when field is a list" do
    it "should not raise exception" do
      filter = LogStash::Filters::Denormalize.new({"source" => "my_array"})
      event = LogStash::Event.new("my_array" => ["cat","dog"])
      
      expect {filter.filter(event).length}.to eq(2)
    end
  end


=begin

  context "when field is nil" do
    it "should not raise exception" do
      filter = LogStash::Filters::Denormalize.new({"source" => "my_array"})
      event = LogStash::Event.new("my_array" => nil)
      expect {filter.filter(event)}.not_to raise_error
    end
  end

 describe "array input" do
    config <<-CONFIG
      filter {
        denormalize { "source" => "message"}
      }
    CONFIG

    sample ["cheese", "bacon"] do
      puts subject.inspect # TODO
      insist { subject.length } == 2
      insist { subject[0]["message"] } == "cheese"
      insist { subject[1]["message"] } == "bacon"
    end
  end

  context "when field is not iterable" do
    it "should not raise exception" do
      filter = LogStash::Filters::Denormalize.new({"source" => "my_array"})
      event = LogStash::Event.new("my_array" => "ipsum lorem")
      expect {filter.filter(event)}.not_to raise_error
    end
  end



  describe "change target name" do
    config <<-CONFIG
      filter {
        denormalize { 
          "source" => "message"
          "target" => "new_key"
        }
      }
    CONFIG

    sample ["cheese", "bacon"] do
      puts subject.inspect # TODO
      insist { subject.length } == 2
      insist { subject[0]["new_key"] } == "cheese"
      insist { subject[1]["new_key"] } == "bacon"
    end
  end


  describe "hash input" do
    config <<-CONFIG
      filter {
        denormalize { "source" => "message"}
      }
    CONFIG

    sample {"foo" => "bar", "unicorn" => "magic"} do
      insist { subject.length } == 2
      insist { subject[0]["foo"] }      == "bar"
      insist { subject[1]["unicorn"] }  == "magic"
    end
  end

  describe "hash input with target name" do
    config <<-CONFIG
      filter {
        denormalize { 
          "source" => "message"
          "target" => "new_key"
        }
      }
    CONFIG

    sample {"foo" => "bar", "unicorn" => "magic"} do
      insist { subject.length } == 2
      insist { subject[0]["new_key"] }      == "bar"
      insist { subject[1]["new_key"] }  == "magic"
    end
  end
=end

end