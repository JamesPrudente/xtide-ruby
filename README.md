# xtide-ruby

## Setup
* Add `config/initializers/tide_path.rb`
```ruby
module Tide
  
  class TidePathNotFoundException < StandardError #:nodoc:
  end
  
  # Manages the path to the tide executable for the different operating 
  # environments.
  class TidePath
    # Read the path for the current ENV
    p Rails.root.to_s + '/config/tide_path.yml'
    unless File.exist?(Rails.root.to_s + '/config/tide_path.yml')
      raise TidePathNotFoundException.new("File RAILS_ROOT/config/tide_path.yml not found")
    else
      env = ENV['RAILS_ENV'] || RAILS_ENV
      TIDE_PATH = YAML.load_file(Rails.root.to_s + '/config/tide_path.yml')[env]
    end
    
    # Returns the path to the tide executable.
    def self.get
      TIDE_PATH
    end
  end
end
```
* copy `tide_path.yml.sample` to `config/tide_path.yml`

## Usage
### Location
```ruby
Tide::Location.list
=> [#<Tide::Location:0x000001024f1d90 @name="0.2 mile off Flat Point, Taku Inlet, Stephens Passa", @loc_type="SUB", @lat=58.3333, @lng=-134.05>, #<Tide::Location:0x000001024f1520 @name="0.2 mile off Taku Point, Taku Inlet, Stephens Passa", @loc_type="SUB", @lat=58.4, @lng=-134.0167>]

Tide::Location.where(name: 'Boston')
=> [#<Tide::Location:0x00000101dd3040 @name="Amelia Earhart Dam, Mystic River, Boston Harbor, Massachusetts", @loc_type="Ref", @lat=42.395, @lng=-71.0767>, #<Tide::Location:0x00000101dd2988 @name="Amelia Earhart Dam, Mystic River, Boston Harbor, Massachusetts", @loc_type="Sub", @lat=42.395, @lng=-71.0767>]

Tide::Location.find_by_name("Amelia Earhart Dam, Mystic River, Boston Harbor, Massachusetts")
=> #<Tide::Location:0x0000010b040220 @name="Amelia Earhart Dam, Mystic River, Boston Harbor, Massachusetts", @loc_type="REF", @lat=42.395, @lng=-71.0767, @country="U.S.A.", @time_zone="America/New_York", @restriction="Public domain", @reference=nil>

Tide::Location.near(lat: 42.4218516, lng: -71.3720429)
=> [#<Tide::Location:0x0000010505d088 @name="Amelia Earhart Dam, Mystic River, Boston Harbor, Ma", @loc_type="REF", @lat=42.395, @lng=-71.0767, @distance=15.180845861787052, @units=:miles>, #<Tide::Location:0x0000010505cac0 @name="Amelia Earhart Dam, Mystic River, Boston Harbor, Ma", @loc_type="SUB", @lat=42.395, @lng=-71.0767, @distance=15.180845861787052, @units=:miles>]

Tide::Location.near(lat: 42.4218516, lng: -71.3720429, threshold: 100.0, units: :kilometers)
=> [#<Tide::Location:0x000001090b9ed8 @name="Amelia Earhart Dam, Mystic River, Boston Harbor, Ma", @loc_type="REF", @lat=42.395, @lng=-71.0767, @distance=24.431142479208376, @units=:kilometers>, #<Tide::Location:0x000001090b3a88 @name="Amelia Earhart Dam, Mystic River, Boston Harbor, Ma", @loc_type="SUB", @lat=42.395, @lng=-71.0767, @distance=24.431142479208376, @units=:kilometers>]
```

### Event
```ruby
Tide::Event.by_location("Amelia Earhart Dam, Mystic River, Boston Harbor, Massachusetts", Date.yesterday.to_time, Date.today.to_time)
=> {:day=>"Thursday, February 20, 2014", :date=>2014-02-20 00:00:00 UTC, :events=>[#<Tide::Event:0x000001093b1690 @event_time="02:22 AM", @event_type="High Tide", @tide_height="10.02 ft">, #<Tide::Event:0x000001093abf38 @event_time="06:33 AM", @event_type="Sunrise", @tide_height="">, #<Tide::Event:0x000001093aa930 @event_time="08:45 AM", @event_type="Low Tide", @tide_height="0.19 ft">, #<Tide::Event:0x000001093a9260 @event_time="09:07 AM", @event_type="Moonset", @tide_height="">, #<Tide::Event:0x000001093a3b80 @event_time="02:47 PM", @event_type="High Tide", @tide_height="9.46 ft">, #<Tide::Event:0x000001093a2500 @event_time="05:22 PM", @event_type="Sunset", @tide_height="">, #<Tide::Event:0x000001093a0ed0 @event_time="09:04 PM", @event_type="Low Tide", @tide_height="0.45 ft">, #<Tide::Event:0x0000010939bca0 @event_time="11:21 PM", @event_type="Moonrise", @tide_height="">]}
```

### Graph
```ruby
Tide::Graph.by_location("Amelia Earhart Dam, Mystic River, Boston Harbor, Massachusetts", 2014, 2, 21)
=> #<Tide::Graph:0x00000109110c38 @location=#<Tide::Location:0x000001092a26a0>, @events={ ... }, @series=[[1392958800.0, 5.407597], [1392959700.0, 5.962987], [1392960600.0, 6.499803]]>
```

## TODO
* Create rake task for `tide_path.yml.sample`
* Add tide_path initializer to gem code

## Acknowledgement
* David Flatter - XTide: Harmonic tide clock and tide predictor (http://www.flaterco.com/xtide).
* Jeff Barriault - XTideOnRails (https://github.com/barriault/XTideOnRails)