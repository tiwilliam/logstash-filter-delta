# encoding: utf-8
require 'spec_helper'
require "logstash/filters/delta"

describe LogStash::Filters::Delta do
  let(:config) { '''
    filter {
      delta {
        between_fields => {"start" => "end"}
        output_field => "output"
      }
    }
  ''' }

  describe "Test missing fields" do
    sample("message" => "abc") do
      expect(subject.get("output")).to eq(nil)
      expect(subject.get("tags")).to eq(["_deltafailure"])
    end

    sample("start" => 100) do
      expect(subject.get("output")).to eq(nil)
      expect(subject.get("tags")).to eq(["_deltafailure"])
    end

    sample("end" => 100) do
      expect(subject.get("output")).to eq(nil)
      expect(subject.get("tags")).to eq(["_deltafailure"])
    end
  end

  describe "Write delta to field" do
    sample("start" => 100, "end" => 250) do
      expect(subject.get("output")).to eq(150)
      expect(subject.get("tags")).to eq(nil)
    end

    sample("start" => 10.5, "end" => 25.3) do
      expect(subject.get("output")).to eq(14.8)
      expect(subject.get("tags")).to eq(nil)
    end

    sample("start" => 10.5, "end" => 25) do
      expect(subject.get("output")).to eq(14.5)
      expect(subject.get("tags")).to eq(nil)
    end
  end

  describe "Dates are not supported" do
    sample("start" => "2015-01-01T01:01:01Z", "end" => "2015-01-01T02:01:01Z") do
      expect(subject.get("output")).to eq(nil)
      expect(subject.get("tags")).to eq(["_deltafailure"])
    end
  end
end

describe LogStash::Filters::Delta do
  let(:config) { '''
    filter {
      delta {
        between_fields => {"start" => "end"}
        output_field => "output"
        max => 100
        min => -10
      }
    }
  ''' }

  describe "Test min and max boundaries with output field" do
    sample("start" => 200, "end" => 300) do
      expect(subject.get("output")).to eq(100)
      expect(subject.get("tags")).to eq(nil)
    end

    sample("start" => 200, "end" => 190) do
      expect(subject.get("output")).to eq(-10)
      expect(subject.get("tags")).to eq(nil)
    end

    sample("start" => 200, "end" => 400) do
      expect(subject.get("output")).to eq(nil)
      expect(subject.get("tags")).to eq(["_deltafailure"])
    end

    sample("start" => 200, "end" => 180) do
      expect(subject.get("output")).to eq(nil)
      expect(subject.get("tags")).to eq(["_deltafailure"])
    end
  end
end

describe LogStash::Filters::Delta do
  let(:config) { '''
    filter {
      delta {
        between_fields => {"start" => "end"}
        max => 100
        min => -10
      }
    }
  ''' }

  describe "Test min and max boundaries" do
    sample("start" => 200, "end" => 400) do
      expect(subject.get("tags")).to eq(["_deltafailure"])
    end

    sample("start" => 200, "end" => 180) do
      expect(subject.get("tags")).to eq(["_deltafailure"])
    end
  end
end

describe LogStash::Filters::Delta do
  let(:config) { '''
    filter {
      delta {
        between_fields => {"start" => "end"}
        max => 100
        min => -10
        tag_on_min_failure => ["_minfail"]
        tag_on_max_failure => ["_maxfail"]
      }
    }
  ''' }

  describe "Test min and max boundaries with custom tags" do
    sample("start" => 200, "end" => 400) do
      expect(subject.get("tags")).to eq(["_maxfail"])
    end

    sample("start" => 200, "end" => 180) do
      expect(subject.get("tags")).to eq(["_minfail"])
    end
  end
end
