# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/util/decorators"

# TODO docu
class LogStash::Filters::Denormalize < LogStash::Filters::Base
  
  config_name "denormalize"

  # The name of the field which contains the array or hash value(s)
  config :source, :validate => :string

  # New name for the splitted field in the new events, if it is not a hash
  config :target, :validate => :string, :default => ""

  # Delete the original event after it has been splitted
  config :delete_original, :validate => :boolean, :default => true

  public
  def register
    @list_target = (@target.nil? || @target.empty?) ? @source : @target # if no target name is provided: keep original name.

  end # def register

  public
  def filter(event)
    input = event.get(@source)
    if !input.nil?  
      if input.is_a?(::Hash) # if it's a hash then let's take the keys from the original data
        input.each do |key, value|
          target = (!@target.nil? && !@target.empty?) ? @target : key
          e = create_child_event(event, target, value)
          yield e
        end # do
      elsif (input.is_a? Enumerable)
        input.each do |value|
          e = create_child_event(event, @list_target, value)
          yield e
        end # do 
          
      else
        @logger.debug("Not iterable: field " + @source + " with value " + input.to_s)
      end
      if @delete_original
        event.cancel
      end 
    else
       @logger.debug("Nil: field " + @source)
    end # if input.nil? 
  end # def filter  

  private
  def create_child_event(event, target, value)
    event_split = event.clone
    event_split.set(target, value)
    LogStash::Util::Decorators.add_tags(["denormalized"],event,"filters/#{self.class.name}")
    filter_matched(event) 
    event_split
  end

end # class LogStash::Filters::List2fields


