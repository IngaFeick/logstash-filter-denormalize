# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

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
          event_split = event.clone
          event_split.set(target, value)
          filter_matched(event_split) 
          yield event_split
          if @delete_original
            event.cancel # TODO why is this here and not outside the loop?
          end
        end # do
      elsif (input.is_a? Enumerable)
        input.each do |value|
          # magic(event, @target, value)
          event_split = event.clone
          event_split.set(@list_target, value)
          filter_matched(event_split)
          yield event_split
          if @delete_original
            event.cancel # TODO why is this here and not outside the loop?
          end
        end # do    
      else
        @logger.debug("Not iterable: field " + @source + " with value " + input.to_s)
      end
    else
       @logger.debug("Nil: field " + @source)
    end # if input.nil? 
  end # def filter  


end # class LogStash::Filters::List2fields


