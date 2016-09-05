# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

class LogStash::Filters::Delta < LogStash::Filters::Base

  config_name "delta"

  # Hash with one key representing start and value representing end.
  config :between_fields, :validate => :hash, :required => true

  # In which field to store delta value on match.
  config :output_field, :validate => :string

  # Minimum delta allowed for match.
  config :min, :validate => :number

  # Maximum delta allowed for match.
  config :max, :validate => :number

  # Append values to the `tags` field on generic failure.
  config :tag_on_failure, :validate => :array, :default => ["_deltafailure"]

  # Append values to the `tags` field on min failure.
  config :tag_on_min_failure, :validate => :array, :default => ["_deltafailure"]

  # Append values to the `tags` field on max failure.
  config :tag_on_max_failure, :validate => :array, :default => ["_deltafailure"]

  private
  def filter_failed(event, tags)
    tags.each {|tag| event.tag(tag)}
  end

  private
  def cast_string_to_numeric(value)
    begin
      return Integer(value)
    rescue ArgumentError
      return Float(value)
    end
  end

  private
  def ensure_numeric(value)
    if (value.is_a? Float or value.is_a? Integer)
      return value
    end
    return cast_string_to_numeric(value)
  end

  public
  def register
  end

  public
  def filter(event)
    delta = 0

    if @between_fields.length != 1
      return filter_failed(event, @tag_on_failure)
    end

    @between_fields.each do |from, to|
      if !event.include?(from) or !event.include?(to)
        return filter_failed(event, @tag_on_failure)
      end

      begin
        delta = ensure_numeric(event.get(to)) - ensure_numeric(event.get(from))
      rescue ArgumentError
        return filter_failed(event, @tag_on_failure)
      end

      if @min and delta < @min
        return filter_failed(event, @tag_on_min_failure)
      end

      if @max and delta > @max
        return filter_failed(event, @tag_on_max_failure)
      end
    end

    if !@output_field.nil?
      event.set(@output_field, delta)
    end

    filter_matched(event)
  end
end
