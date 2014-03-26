class LocationNotFoundException < StandardError
end

module Tide
  class Location

    require 'nokogiri'
    require 'geocoder'

    attr_accessor :name, :lat, :lng, :country, :time_zone, :restriction, :loc_type, :reference, :distance, :units

    def initialize(params = {})
      params.each do |i,v|
        self.send("#{i}=".to_sym, v)
      end
    end

    def units(events = nil)
      events ||= Tide::Event.by_location(@name, Time.now, Time.now.advance(days: 1))[:events]
      events.reject { |e| e.tide_height.blank? }.first.tide_height.include?('ft') ? 'ft' : 'm'
    end

    def current_tide(series = nil)
      date = Time.now
      series ||= Tide::Graph.by_location(@name, date.year, date.month, date.day).series
      series.min_by { |p| (p.x.to_f - date.to_i).abs }.y
    end

    def todays_high(series = nil)
      date = Time.at(series.first.x).in_time_zone(@time_zone)
      end_of_day = date.end_of_day.to_i
      series ||= Tide::Graph.by_location(@name, date.year, date.month, date.day).series
      series.reject! { |p| p.x > end_of_day }
      y_values = series.collect { |p| p.y }
      index = y_values.index(y_values.max)
      series[index]
    end

    def todays_low(series = nil)
      date = Time.at(series.first.x).in_time_zone(@time_zone)
      end_of_day = date.end_of_day.to_i
      series ||= Tide::Graph.by_location(@name, date.year, date.month, date.day).series
      series.reject! { |p| p.x > end_of_day }
      y_values = series.collect { |p| p.y }
      index = y_values.index(y_values.min)
      series[index]
    end

    def self.list
      array = []
      raw_data = Command.list
      raw_data[2..raw_data.length - 1].each do |line|
        name = line[0..50]
        type = line[52..54].upcase
        coords = Location.get_coordinates(line)
        array << Location.new({ :name => name.rstrip, :loc_type => type, :lat => coords[0], :lng => coords[1] })
      end
      return array
    end

    def self.where(args)
      array = []
      raw_data = Command.list_html
      doc = Nokogiri::HTML(raw_data.join)
      rows = doc.search('tr').reject { |r| r.children.collect { |c| c.name }.include? 'th' }
      rows[1..-1].each do |row|
        next unless row.children[0].text =~ /#{args[:name]}/

        name = row.children[0].text
        type = row.children[1].text
        coords = Location.get_coordinates_from_html(row.children[2].text)
        array << Location.new({ :name => name.rstrip, :loc_type => type, :lat => coords[0], :lng => coords[1] })
      end
      return array
    end

    # Returns the <tt>Location</tt> for +name+.
    def self.find_by_name(name)
      raw_data = Command.about(name)
      loc = Location.new
      # figure out columns in data
      a = raw_data[0].reverse.chop.chop.chop.chop.reverse.strip
      i = raw_data[0].index(a)

      # create a hash of all the input lines
      hash = Hash.new
      raw_data.each do |line|
        key = line[0..i-1].rstrip
        value = line[i..line.length - 1].rstrip
        hash[key] = value
      end

      # Search the hash and assign values to attributes
      loc.name = hash["Name"]

      unless hash["Coordinates"].nil?
        coordinates = hash["Coordinates"].split(",")
        re = /(\d+).(\d+)/
        md = re.match(coordinates[0])
        if coordinates[0] =~ /S/
          loc.lat = (-1.0 * md[0].to_f)
        else
          loc.lat = (md[0].to_f)
        end
        md = re.match(coordinates[1])
        if coordinates[1] =~ /W/
          loc.lng = (-1.0 * md[0].to_f)
        else
          loc.lng = (md[0].to_f)
        end
      end

      loc.country = hash["Country"]

      unless hash["Time zone"].nil?
        tz = hash["Time zone"]
        if tz.include?(":")
          loc.time_zone = tz.reverse.chop.reverse
        else
          loc.time_zone = tz
        end
      end

      loc.restriction = hash["Restriction"]

      type = hash["Type"]
      unless type.nil?
        if type =~ /Reference station, tide/
          loc.loc_type = "REF"
        else
          loc.loc_type = "SUB"
        end
      end

      loc.reference = hash["Reference"]

      return loc
    rescue TideFatalException
      STDERR.puts "location #{name} not found"
      raise LocationNotFoundException.new("location #{name} not found")
    end

    def self.near(args)
      locations = []
      units = args[:units] || :miles
      threshold = args[:threshold] || 50.0
      threshold *= 0.621371 if units == :kilometers

      Location.list.each do |loc|
        distance_in_miles = Geocoder::Calculations.distance_between([args[:lat], args[:lng]], [loc.lat, loc.lng])
        distance_in_kilometers = distance_in_miles * 1.60934
        distance_for_threshold = units == :miles ? distance_in_miles : distance_in_kilometers

        if distance_for_threshold < threshold
          loc.distance = distance_for_threshold
          loc.units = units
          locations << loc
        end
      end
      locations.sort_by { |l| l.distance }
    end

    private

    def self.get_coordinates(line)
      coords = []
      array = line[56..line.length].chomp.split(",")
      re = /(\d+).(\d+)/
      md = re.match(array[0])
      if array[0] =~ /S/
        coords[0] = (-1.0 * md[0].to_f)
      else
        coords[0] = (md[0].to_f)
      end
      md = re.match(array[1])
      if array[1] =~ /W/
        coords[1] = (-1.0 * md[0].to_f)
      else
        coords[1] = (md[0].to_f)
      end
      return coords
    end

    def self.get_coordinates_from_html(line)
      coords = []
      array = line.unpack("C*").pack("U*").split(",")
      re = /(\d+).(\d+)/
      md = re.match(array[0])
      if array[0] =~ /S/
        coords[0] = (-1.0 * md[0].to_f)
      else
        coords[0] = (md[0].to_f)
      end
      md = re.match(array[1])
      if array[1] =~ /W/
        coords[1] = (-1.0 * md[0].to_f)
      else
        coords[1] = (md[0].to_f)
      end
      return coords
    end
  end

end
