module BouncingShape
  PRECISION = 0.00000001

  def self.normal(vector)
    length = Math.sqrt(vector[0] ** 2 + vector[1] ** 2)
    [ -vector[1] / length, vector[0] / length ]
  end

  def self.scale(vector,factor)
    [ factor * vector[0], factor * vector[1] ]
  end

  def self.magnitude(vx,vy)
    Math.sqrt(vx ** 2 + vy ** 2)
  end

  def self.length(segment)
    Math.sqrt( (segment[2] - segment[0]) ** 2 +
               (segment[3] - segment[1]) ** 2 )
  end

  def self.distance(point1,point2)
    Math.sqrt( (point2[0] - point1[0]) ** 2 +
               (point2[1] - point1[1]) ** 2 )
  end

  def self.dot_product(vector1,vector2)
    vector1[0] * vector2[0] + vector1[1] * vector2[1]
  end

  def self.inside_segment?(segment,point)
    x_min, x_max  = segment[0], segment[2]
    x_min, x_max  = x_max, x_min if segment[0] > segment[2]

    y_min, y_max  = segment[1], segment[3]
    y_min, y_max  = y_max, y_min if segment[1] > segment[3]

    point[0].between?(x_min, x_max) && point[1].between?(y_min, y_max)
  end
end
