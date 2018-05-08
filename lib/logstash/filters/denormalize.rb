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
  config :add_child_tag, :validate => :string, :default => "denormalized" # TODO I think this is not needed anymore because logstash has a mechanism for that already? or is it a different functionality? If so: document why

  # Add the list position of the denormalized list entry to the event. Helpful for debugging or id generation. Adds the field 'meta_position'
  config :add_position, :validate => :boolean, :default => false

  public
  def register
    @list_target = (@target.nil? || @target.empty?) ? @source : @target # if no target name is provided: keep original name.
  end # def register

  public
  def filter(event)
    input = event.get(@source)
    if !input.nil?
      case input
      when ::Hash # if it's a hash then let's take the keys from the original data
        input.each_with_index do | (key, value), index| # TODO write tests for both iterations
          target = (!@target.nil? && !@target.empty?) ? @target : key
          yield create_child_event(event, target, value, index)          
        end # do
      when Enumerable
        input.each_with_index do |value, index|
          yield create_child_event(event, @list_target, value, index)
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
  def create_child_event(event, target, value, index)
    event_split = event.clone
    event_split.set(target, value)
    if @add_position
      event_split.set('meta_position', index)
    end
    LogStash::Util::Decorators.add_tags([@add_child_tag],event_split,"filters/#{self.class.name}")
    filter_matched(event)
    event_split
  end

end # class LogStash::Filters::List2fields


