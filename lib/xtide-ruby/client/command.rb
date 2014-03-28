module Tide

  class TideFatalException < StandardError #:nodoc:
  end

  module Client

    class Command

      def self.execute(options = {})
        command = Client.path
        if options.kind_of? Hash
          if options.key?(:b)
            b = options[:b].strftime("%Y-%m-%d %H:%M")
            command << " -b \"#{b}\""
          end

          if options.key?(:e)
            e = options[:e].strftime("%Y-%m-%d %H:%M")
            command << " -e \"#{e}\""
          end

          if options[:z]
            command << " -z"
          end

          if options.key?(:f)
            command << " -f #{options[:f]}"
          end

          if options.key?(:l)
            location = options[:l]
            if location =~ /"/
              command << " -l '#{location}'"
            else
              command << " -l \"#{location}\""
            end
          end

          if options.key?(:m)
            command << " -m #{options[:m]}"
          end

          if options.key?(:ml)
            command << " -ml #{options[:ml]}"
          end

          if options.key?(:o)
            command << " -o \"#{options[:o]}\""
          end

          if options.key?(:s)
            s = options[:s]
            command << " -s \"#{s}\""
          end

          if options[:v]
            command << " -v"
          end
        else
          command << options
        end

        data = IO.popen(command)
        raw_data = data.readlines.map { |l| l.force_encoding("ISO-8859-1").encode("UTF-8") }
        data.close

        if raw_data.empty?
          raise TideFatalException.new("No results returned for command: #{command}")
        else
          return raw_data
        end
      end

      # tide -m l
      def self.list
        execute({:m => 'l'})
      end

      # tide -m l -f h
      def self.list_html
        execute({:m => 'l', :f => 'h'})
      end

      # tide -m a -l +name+
      def self.about(name)
        execute({:m => 'a', :l => name})
      end

      # tide -m a -f h -l +name+d
      def self.about_html(name)
        execute({:m => 'a', :f => 'h', :l => name})
      end

      # tide -l +name+ -b +begin_time+ -e +end_time+ -z
      def self.plain(name, begin_time = nil, end_time = nil, utc = true)
        cmd = { :l => name, :z => utc }
        cmd[:b] = begin_time if begin_time
        cmd[:e] = end_time if end_time
        execute(cmd)
      end

      # tide -l +name+ -b +begin_time+ -e +end_time+ -z -f c
      def self.plain_csv(name, begin_time = nil, end_time = nil, utc = true)
        cmd = { :l => name, :z => utc, :f => 'c' }
        cmd[:b] = begin_time if begin_time
        cmd[:e] = end_time if end_time
        execute(cmd)
      end

      # tide -m r -l +name+ -b +begin_time+ -e +end_time+ -z -s +interval+
      def self.raw(name, begin_time = nil, end_time = nil, utc = true, interval = "00:15")
        cmd = { :m => 'r', :l => name, :s => interval, :z => utc }
        cmd[:b] = begin_time if begin_time
        cmd[:e] = end_time if end_time
        execute(cmd)
      end

      # tide -m r -l +name+ -b +begin_time+ -e +end_time+ -z -f c
      def self.raw_csv(name, begin_time = nil, end_time = nil, utc = true, interval = "00:15")
        cmd = { :m => 'r', :l => name, :s => interval, :z => utc, :f => 'c' }
        cmd[:b] = begin_time if begin_time
        cmd[:e] = end_time if end_time
        execute(cmd)
      end

      # tide -m m -l +name+ -b +begin_time+ -e +end_time+ -z
      def self.medium_rare(name, begin_time = nil, end_time = nil, utc = true)
        cmd = { :m => 'm', :l => name, :z => utc }
        cmd[:b] = begin_time if begin_time
        cmd[:e] = end_time if end_time
        execute(cmd)
      end

      # tide -m m -l +name+ -b +begin_time+ -e +end_time+ -z -f c
      def self.medium_rare_csv(name, begin_time = nil, end_time = nil, utc = true)
        cmd = { :m => 'm', :l => name, :z => utc, :f => 'c' }
        cmd[:b] = begin_time if begin_time
        cmd[:e] = end_time if end_time
        execute(cmd)
      end

      # tide -s m -l +name+ -b +begin_time+ -e +end_time+ -z
      def self.stats(name, begin_time = nil, end_time = nil, utc = true)
        cmd = { :m => 's', :l => name, :z => utc }
        cmd[:b] = begin_time if begin_time
        cmd[:e] = end_time if end_time
        execute(cmd)
      end

    end

  end

end
