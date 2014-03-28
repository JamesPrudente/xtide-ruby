module Tide

  module Client

    @@path = 'tide'

    def self.new(options = {})
      @@path = options[:path] || 'tide'
      self
    end

    def self.path
      @@path
    end

  end

end
