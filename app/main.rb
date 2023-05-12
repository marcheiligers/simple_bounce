require 'lib/bouncing_shape.rb'
require 'lib/static_vector.rb'
require 'lib/segment.rb'
require 'lib/circle.rb'





#
CROSS_SIZE          = 4
INTERSECTION_COLOR  = [0, 0, 255, 255]





################################################################################
# 1. Setup :
################################################################################
def setup(args)
  # 1.1 Create BOUNCING SHAPES :

  # Create a SEGMENT ... :
  a_segment = BouncingShape::Segment.new( [ 100 + rand * 1080,        # x1
                                             50 + rand * 620,         # y1
                                            100 + rand * 1080,        # x2
                                             50 + rand * 620 ],       # y2
                                            1.0,                      # how strong the bounce is
                                            [ 255, 0, 255, 255 ] )    # color

  # ... and create a CIRCLE :
  a_circle  = BouncingShape::Circle.new(  [ 200 + rand * 880, 100 + rand * 520 ], # center
                                            50 + 100 * rand,                      # radius
                                            1.0,                                  # bounce strength
                                            [ 255, 0, 255, 255 ] )                # color

  # Collect SEGMENT and CIRCLE in a array of SHAPES :
  args.state.shapes = [ a_segment, a_circle]


  # 1.2 Miscellaneous :
  args.state.center = [ args.grid.right / 2, args.grid.top / 2 ]  # for our basic input
  args.state.setup_done = true;
end





################################################################################
# 2. Tick :
################################################################################
def tick(args)
  # 2.1 Setup :
  setup(args) unless args.state.setup_done


  # 2.2 User Input :
  x             = args.inputs.mouse.x
  y             = args.inputs.mouse.y

  # Create a STATIC VECTOR that can collide with SHAPES :
  # (it's a simple vector between the center of the screen ...
  # (... and the mouse position)
  displacement  = BouncingShape::StaticVector.new args.state.center[0],   # x1
                                              args.state.center[1],       # y1
                                              x,                          # x2
                                              y                           # y2


  # 2.3 SHAPES Update :
  args.state.shapes.each do |shape|
    # Check for an intersection :
    # The status of the intersection is given by BouncingShape#intersection.
    shape.intersect? displacement

    # If the intersection exists, calculate the bounce vector :
    # The bounce vector is given by BouncingShape#reflection.
    shape.calculate_bounce displacement if shape.intersection[:exist]
  end

  # Rendering :
  #displacement.draw(args, [0, 255, 0, 255])
  displacement.draw(args)

  args.state.shapes.each do |shape|
    shape.draw(args)  # the SHAPES can draw themselves and the ...
                      # ... reflection of the displacement.

    draw_cross_at(shape.intersection[:at],
                  CROSS_SIZE,
                  INTERSECTION_COLOR) if shape.intersection[:exist]
  end
end





################################################################################
# 3. Tools :
################################################################################
def draw_cross_at(point,size,color)
  $gtk.args.outputs.lines <<  [ point.x - size, point.y + size,
                                point.x + size, point.y - size ] + color
  $gtk.args.outputs.lines <<  [ point.x + size, point.y + size,
                                point.x - size, point.y - size ] + color
end
