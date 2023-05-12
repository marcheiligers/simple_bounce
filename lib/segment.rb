module BouncingShape
  class Segment
    attr_reader :segment,
                :normal,
                :strength,
                :intersection,
                :reflection

    def initialize(segment,strength=1.0,color=[255,0,0,255])
      @as_vector    = BouncingShape::StaticVector.new *segment

      @intercept  = @as_vector.y2 - @as_vector.slope * @as_vector.x2

      @strength = strength

      @color  = color

      @intersection         = { exist: false, at: [ Float::NAN, Float::NAN ] }
      @croped_displacement  = [ Float::NAN, Float::NAN ]
      @reflection           = [ Float::NAN, Float::NAN ]
    end

    def intersect?(displacement)
      @intersection[:exist] = false
      @intersection[:at][0] = Float::NAN
      @intersection[:at][1] = Float::NAN

      return if ( @as_vector.slope - displacement.slope ).abs < PRECISION

      # If they aren't :
      displacement_intercept  = displacement.y2 - displacement.slope * displacement.x2

      @intersection[:at][0] = ( @intercept - displacement_intercept ) /
                              ( displacement.slope - @as_vector.slope )
      @intersection[:at][1] = @as_vector.slope * @intersection[:at][0] + @intercept

      # Checking if the intersection is in the same direction that the ...
      # ... semgent/vector points to :
      if  ( @intersection[:at][0] > displacement.x1 && displacement.x2 > displacement.x1 ) ||
          ( @intersection[:at][0] < displacement.x1 && displacement.x2 < displacement.x1 )
        # Checking that the intersection is inside the segment and ...
        # ... displacement :
        if  BouncingShape.inside_segment?(@as_vector.segment,   @intersection[:at]) &&
            BouncingShape.inside_segment?(displacement.segment, @intersection[:at])
          @intersection[:exist] = true

        end
      end
    end

    def calculate_bounce(displacement)
      @croped_displacement  = [ @intersection[:at][0] - displacement.x1,
                                @intersection[:at][1] - displacement.y1 ]

      normal_dot_displacement = 2 * BouncingShape.dot_product(@as_vector.normal,
                                                              @croped_displacement)
      base_reflection_x = @croped_displacement[0] -
                          normal_dot_displacement * @as_vector.normal[0]
      base_reflection_y = @croped_displacement[1] -
                          normal_dot_displacement * @as_vector.normal[1]

      base_reflection_magnitude = BouncingShape.magnitude(base_reflection_x,
                                                          base_reflection_y)

      @reflection[0]  = @strength * displacement.magnitude * base_reflection_x /
                        base_reflection_magnitude
      @reflection[1]  = @strength * displacement.magnitude * base_reflection_y /
                        base_reflection_magnitude
    end

    def tick(args)
    end

    def draw(args)
      # The segment itself :
      args.outputs.lines << @as_vector.segment + @color

      middle_x  = @as_vector.segment[0] +
                  ( @as_vector.segment[2] - @as_vector.segment[0] ) / 2
      middle_y  = @as_vector.segment[1] +
                  ( @as_vector.segment[3] - @as_vector.segment[1] ) / 2

      # The normal :
      args.outputs.lines << [ middle_x,
                              middle_y,
                              middle_x + 40 * @as_vector.normal[0],
                              middle_y + 40 * @as_vector.normal[1] ] + @color

      # The reflection :
      if @intersection[:exist]
        # Normal :
        args.outputs.lines << [ @intersection[:at][0],
                                @intersection[:at][1],
                                @intersection[:at][0] + 40 * @as_vector.normal[0],
                                @intersection[:at][1] + 40 * @as_vector.normal[1] ] + [ 255, 127, 0, 255 ]

        # Reflection :
        args.outputs.lines << [ @intersection[:at][0],
                                @intersection[:at][1],
                                @intersection[:at][0] + @reflection[0],
                                @intersection[:at][1] + @reflection[1] ] + [ 255, 0, 0, 255 ]
      end
    end
  end
end
