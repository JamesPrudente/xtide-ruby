module Tide

  class Event
    attr_accessor :event_time, :event_type, :tide_height

    def initialize(params = {})
      params.each do |i,v|
        self.send("#{i}=".to_sym, v)
      end
    end

    def self.by_location(name, begin_time, end_time)
      location = Location.find_by_name(name)
      by_location( location, name, begin_time, end_time)
    end

    # Return the <tt>Events</tt> for the given location +name+.
    def self.by_location( location, name, begin_time, end_time)

      tz = TZInfo::Timezone.get(location.time_zone)
      b = tz.local_to_utc(begin_time)
      e = tz.local_to_utc(end_time)

      events = []

      Client::Command.plain_csv(name, b, e).each do |line|
        fields = line.split(",")
        time = Time.parse(fields[1] + " " + fields[2])
        event_time = tz.utc_to_local(time).strftime("%I:%M %p")
        tide_height = fields[3]
        event_type = fields[4].gsub /\n/, ''
        event = Event.new(:event_time => event_time, :event_type => event_type, :tide_height => tide_height)
        events << event
      end
      return { :day => tz.utc_to_local(b).strftime("%A, %B %d, %Y"), :date => tz.utc_to_local(b), :events => events }
    end

  end

end
