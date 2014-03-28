module Tide

  class Point
    attr_accessor :x, :y

    def initialize(params = {})
      params.each do |i,v|
        self.send("#{i}=".to_sym, v)
      end
    end

    def inspect
      "[#{x}, #{y}]"
    end
  end

end
