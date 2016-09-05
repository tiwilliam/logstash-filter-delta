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
  def is_numeric(value)
    return (value.is_a?(Integer) or value.is_a?(Float))
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

      to = event.get(to)
      from = event.get(from)

      if !is_numeric(to) or !is_numeric(from)
        return filter_failed(event, @tag_on_failure)
      end

      delta = to - from

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
