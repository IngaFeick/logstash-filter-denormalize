# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
#require "logstash/util/decorators"

# TODO docu
class LogStash::Filters::Denormalize < LogStash::Filters::Base
  
  config_name "denormalize"

  # The name of the field which contains the array or hash value(s)
  config :source, :validate => :string

  # New name for the splitted field in the new events, if it is not a hash
  config :target, :validate => :string, :default => ""

  # Delete the original event after it has been splitted
  config :delete_original, :validate => :boolean, :default => true

  # Tag to be added to the spawned event
  config :add_child_tag, :validate => :string, :default => "denormalized"

  # Mark one of the spawned events 
  config :mark_first_child, :validate => :boolean, :default => false, :required => false

  public
  def register
    @list_target = (@target.nil? || @target.empty?) ? @source : @target # if no target name is provided: keep original name.
  end # def register

  public
  def filter(event)
    input = event.get(@source)
    if !input.nil?
      c = 0
      if input.is_a?(::Hash) # if it's a hash then let's take the keys from the original data
        input.each do |key, value|
          target = (!@target.nil? && !@target.empty?) ? @target : key
          yield create_child_event(event, target, value, c += 1)          
        end # do
      elsif (input.is_a? Enumerable)
        input.each do |value|
          yield create_child_event(event, @list_target, value, c += 1)
        end # do 
      else
        @logger.debug("Not iterable: field " + @source + " with value " + input.to_s)
      end
      event.cancel if @delete_original
      
    else
       @logger.debug("Nil: field " + @source)
    end # if input.nil? 
  end # def filter  

  private
  def create_child_event(event, target, value, counter)
    event_split = event.clone
    event_split.set(target, value)
    LogStash::Util::Decorators.add_tags([@add_child_tag],event_split,"filters/#{self.class.name}")
    if counter == 1 && @mark_first_child
      event_split.set("is_master", true)
    end
    filter_matched(event)
    event_split
  end

end # class LogStash::Filters::List2fields


