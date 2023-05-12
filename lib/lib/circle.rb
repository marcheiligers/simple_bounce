module BouncingShape
  class Circle
    CIRCLE_DETAIL = 16

    attr_reader :center, :radius,
                :strength,
                :intersection,
                :reflection

    def initialize(center,radius,strength=1.0,color=[255,0,0,255])
      @radius   = radius
      @radius2  = radius ** 2
      @center   = center

      @strength = strength

      @color    = color

      @closest_to_displacement_line   = [ Float::NAN, Float::NAN ]
      @distance_to_displacement_line  = Float::NAN
      @intersection_dist_to_closest   = Float::NAN
      @intersection                   = { exist:  false,
                                          at:     [ Float::NAN, Float::NAN ] }

      @reflection = [ Float::NAN, Float::NAN ]
    end

    def intersect?(displacement)
      if displacement.offset[0] * ( @center[0] - displacement.x1 ) >= 0 then
        @closest_to_displacement_line[0]  = displacement.slope *
                                            ( displacement.slope * displacement.x1 +
                                            @center[0] / displacement.slope        +
                                            @center[1]                             -
                                            displacement.y1 ) /
                                            ( 1 + displacement.slope ** 2 )
        @closest_to_displacement_line[1]  = displacement.slope *
                                            ( @closest_to_displacement_line[0] - displacement.x1 ) +
                                            displacement.y1

        @distance_to_displacement_line  = BouncingShape.distance  @closest_to_displacement_line,
                                                                  @center

        if @distance_to_displacement_line <= @radius
          @intersection_dist_to_closest = Math.sqrt(@radius2 -
                                                    @distance_to_displacement_line ** 2)

          displacement_start_dist_to_int  = BouncingShape.distance( displacement.p1,
                                                                    @closest_to_displacement_line) -
                                            @intersection_dist_to_closest

          if displacement.magnitude > displacement_start_dist_to_int
            @intersection[:exist] = true
            return
          end
        end
      end

      @intersection[:exist] = false
    end

    def calculate_bounce(displacement)
      @intersection[:at][0] = @closest_to_displacement_line[0] -
                              @intersection_dist_to_closest * displacement.unit[0]
      @intersection[:at][1] = @closest_to_displacement_line[1] -
                              @intersection_dist_to_closest * displacement.unit[1]

      @croped_displacement  = [ @intersection[:at][0] - displacement.x1,
                                @intersection[:at][1] - displacement.y1 ]

      @normal = [ ( @intersection[:at][0] - @center[0] ) / @radius,
                  ( @intersection[:at][1] - @center[1] ) / @radius ]

      normal_dot_displacement = 2 * BouncingShape.dot_product(@normal,
                                                              @croped_displacement)
      base_reflection_x = @croped_displacement[0] -
                          normal_dot_displacement * @normal[0]
      base_reflection_y = @croped_displacement[1] -
                          normal_dot_displacement * @normal[1]

      base_reflection_magnitude = BouncingShape.magnitude(base_reflection_x,
                                                          base_reflection_y)

      @reflection[0]  = @strength * displacement.magnitude * base_reflection_x /
                        base_reflection_magnitude
      @reflection[1]  = @strength * displacement.magnitude * base_reflection_y /
                        base_reflection_magnitude
    end

    def draw(args)
      # Center :
      draw_cross_at(@center, 5, @color)

      # Circle :
      segment_angle = 2 * Math::PI / CIRCLE_DETAIL
      CIRCLE_DETAIL.times do |i|
        args.outputs.lines << [ @center[0] + @radius * Math::cos(i * segment_angle),
                                @center[1] + @radius * Math::sin(i * segment_angle),
                                @center[0] + @radius * Math::cos((i+1) * segment_angle),
                                @center[1] + @radius * Math::sin((i+1) * segment_angle) ] + @color
      end

      if @intersection[:exist] then
        # Normal :
        args.outputs.lines << [ @intersection[:at][0],
                                @intersection[:at][1],
                                @intersection[:at][0] + 40 * @normal[0],
                                @intersection[:at][1] + 40 * @normal[1] ] + @color 

       # # Reflection :
       args.outputs.lines << [ @intersection[:at][0],
                               @intersection[:at][1],
                               @intersection[:at][0] + @reflection[0],
                               @intersection[:at][1] + @reflection[1] ] + [ 255, 0, 0, 255 ]
      end
    end
  end
end
