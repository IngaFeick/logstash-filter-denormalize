# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/denormalize"
#require "logstash/timestamp"

describe LogStash::Filters::Denormalize do

  describe "list with target key" do
     config <<-CONFIG
      filter {
        denormalize {
          source => "my_array"
          target => "new_field"
        }
      }
    CONFIG

    sample("my_array" => [1,2,3], "some_other_value" => "unchanged") do
      
      subject.each do |s|
         insist { s.get("some_other_value") } == "unchanged"
      end
      insist { subject[0].get("new_field") } == 1
      insist { subject[1].get("new_field") } == 2
      insist { subject[2].get("new_field") } == 3
      insist { subject.length } == 3
    end
  end

  describe "list without target key" do
     config <<-CONFIG
      filter {
        denormalize {
          source => "my_array"       
        }
      }
    CONFIG

    sample("my_array" => [1,2,3]) do    
      insist { subject[0].get("my_array") } == 1
      insist { subject[1].get("my_array") } == 2
      insist { subject[2].get("my_array") } == 3
      insist { subject.length } == 3
    end
  end

  describe "list with target key" do
     config <<-CONFIG
      filter {
        denormalize {
          source => "my_array"
          target => "new_field"
        }
      }
    CONFIG

    sample("my_array" => ["a", "b", "c", true, false, [1,2,3]], "some_other_value" => "unchanged") do
      
      subject.each do |s|
         insist { s.get("some_other_value") } == "unchanged"
      end
      insist { subject[0].get("new_field") } == "a"
      insist { subject[1].get("new_field") } == "b"
      insist { subject[2].get("new_field") } == "c"
      insist { subject[3].get("new_field") } == true
      insist { subject[4].get("new_field") } == false
      insist { subject[5].get("new_field") } == [1,2,3]
      insist { subject.length } == 6
    end    
  end


  describe "dictionary without target key" do
    config <<-CONFIG
      filter {
        denormalize {
          source => "my_dict"
        }
      }
    CONFIG

    sample("my_dict" => {"foo" => "bar", "cheese" => "bacon"}, "some_other_value" => "unchanged") do
      insist { subject.length } == 2
      subject.each do |s|
         insist { s.get("some_other_value") } == "unchanged"
      end
      insist { subject[0].get("foo") } == "bar"
      insist { subject[1].get("cheese") } == "bacon"
    end
  end

  describe "dictionary with target key" do
    config <<-CONFIG
      filter {
        denormalize {
          source => "my_dict"
          target => "new_field"
        }
      }
    CONFIG

    sample("my_dict" => {"foo" => "bar", "cheese" => "bacon"}, "some_other_value" => "unchanged") do
      insist { subject.length } == 2
      subject.each do |s|
         insist { s.get("some_other_value") } == "unchanged"
      end
      insist { subject[0].get("new_field") } == "bar"
      insist { subject[1].get("new_field") } == "bacon"
    end
  end





  context "when field is nil" do
    it "should not raise exception" do
      filter = LogStash::Filters::Denormalize.new({"source" => "my_array"})
      event = LogStash::Event.new("my_array" => nil)
      expect {filter.filter(event)}.not_to raise_error
    end
  end

  context "when field is not iterable" do
    it "should not raise exception" do
      filter = LogStash::Filters::Denormalize.new({"source" => "my_array"})
      event = LogStash::Event.new("my_array" => "ipsum lorem")
      expect {filter.filter(event)}.not_to raise_error
    end
  end

end