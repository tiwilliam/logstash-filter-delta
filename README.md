# Logstash Delta Filter Documentation

[![Travis Build Status](https://travis-ci.org/tiwilliam/logstash-filter-delta.svg)](https://travis-ci.org/tiwilliam/logstash-filter-delta)
[![Gem Version](https://badge.fury.io/rb/logstash-filter-delta.svg)](https://badge.fury.io/rb/logstash-filter-delta)

This filter helps you to calculate integer or float delta and tag based on result or write it to a field.

## Write delta to field

```
delta {
    between_fields => [
        {"start_time" => "end_time"}
    ]
    output_field => "delta_time"
}
```

## Set tag based on delta

```
delta {
  between_fields => [
  	{"backend_epoch" => "client_epoch"}
  ]
  min => -10  # -10 seconds
  max => 600  # +10 minutes
  tag_on_min_failure => ["_event_too_new"]
  tag_on_max_failure => ["_event_too_old"]
}
```

## Filter options

* **between_fields**

  Hash with one key representing start and value representing end. Required.

* **output_field**

  In which field to store delta value on match. Optional.

* **min**

  Minimum delta allowed for match. Optional.

* **max**

  Maximum delta allowed for match. Optional.

* **tag_on_failure**

  Append values to the `tags` field on generic failure. Defaults to `["_deltafailure"]`.

* **tag_on_min_failure**

  Append values to the `tags` field on min failure. Defaults to `["_deltafailure"]`.

* **tag_on_max_failure**

  Append values to the `tags` field on max failure. Defaults to `["_deltafailure"]`.

## Changelog

You read about all changes in [CHANGELOG.md](CHANGELOG.md).

## Need help?

Need help? Try #logstash on freenode IRC or the [Logstash discussion forum](https://discuss.elastic.co/c/logstash).

## Want to contribute?

Get started by reading [BUILD.md](BUILD.md).
