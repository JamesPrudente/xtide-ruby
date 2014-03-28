module Tide

  module Client

    def self.new(options = {})
      @path = options[:path] || 'tide'
      return self
    end

    def self.get_path
      "#{@path}"
    end

  end

end
