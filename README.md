# Logstash denormalize Filter Plugin


This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Installation

You can download the plugin from [rubygems](https://rubygems.org/gems/logstash-filter-denormalize) and install it from your logstash home directory like so:

	bin/plugin install logstash-filter-denormalize-$VERSION.gem

## Purpose

This filter will denormalize an event with a field of n values in an array into n differents events, which are the same except for the values in the array field. Each event will contain one of the array values in that field.  
Basically, it behaves like the [split filter](https://www.elastic.co/guide/en/logstash/current/plugins-filters-split.html) but it splits on objects, not string sections.

### Examples
  
	Input event: 
	{
		"host" => "machine4711"
		"services" => ["elasticsearch","logstash","collectd"]
		"ip" => "10.1.2.3"
	}

Output events:

	{
		"host" => "machine4711"
		"services" => "elasticsearch"
		"ip" => "10.1.2.3"
	}
	{
		"host" => "machine4711"
		"services" => "logstash"
		"ip" => "10.1.2.3"
	}
	{
		"host" => "machine4711"
		"services" => "collectd"
		"ip" => "10.1.2.3"
	}

If the field, upon which the event is to be splitted, contains an array of key=>value nature, then those keys will be used in the new events:

Input event: 
	{
		"host" => "machine4711"
		"attributes" => {
						"ram" => "32g",
						"cores" => 8
						}
		"ip" => "10.1.2.3"
	}

Output events:
	{
		"host" => "machine4711"
		"ram" => "32g"
		"ip" => "10.1.2.3"
	}
	{
		"host" => "machine4711"
		"cores" => 8
		"ip" => "10.1.2.3"
	}

## Configuration

* source 	: name of the field by which to denormalize. For each entry in this field (which should have an array value) a new record will be created, containing all the other fields. 
* target	: new key for the field by which you splitted the event. This is only effective if the splitted field didn't have keys on its own.


## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.