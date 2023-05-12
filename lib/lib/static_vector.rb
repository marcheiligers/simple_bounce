module BouncingShape
  class StaticVector
    attr_reader :x1, :y1, :x2, :y2,
                :p1, :p2,
                :segment,
                :offset, :unit,
                :slope,
                :magnitude,
                :normal

    def initialize(x1,y1,x2,y2)
      update x1, y1, x2, y2
    end

    def update(x1,y1,x2,y2)
      @x1, @y1, @x2, @y2  = x1, y1, x2, y2

      @p1, @p2  = [ x1, y1 ], [ x2, y2 ]

      @segment  = [ x1, y1, x2, y2 ]
      @offset   = [ x2 - x1, y2 - y1 ]

      @slope  = @offset[1] / @offset[0]

      calculate_magnitude
    end

    def update_p1(x1,y1)
      @x1, @y1  = x1, y1

      @segment  = [ x1, y1, x2, y2 ]
      @offset   = [ x2 - x1, y2 - y1 ]

      calculate_magnitude
    end

    def update_p2(x2,y2)
      @x2, @y2  = x2, y2

      @segment  = [ x1, y1, x2, y2 ]
      @offset   = [ x2 - x1, y2 - y1 ]

      calculate_magnitude
    end

    def calculate_magnitude
      @magnitude  = Math.sqrt(@offset[0] **2 + @offset[1] **2)
      
      @unit = [ @offset[0] / @magnitude, @offset[1] / @magnitude ]

      @normal = [ -@unit[1], @unit[0] ]
    end

    def self.dot_with_vec(other)
      @offset[0] * other.offset[0] + @offset[1] * other.offset[1]
    end

    def draw(args,color)
      draw_cross_at(@p1, 4, color)
      args.outputs.lines << @segment + color
      draw_cross_at(@p2, 4, color)
    end
  end
end

