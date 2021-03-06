require 'complex'

class Point
  attr_reader :complex

  def initialize(*args)
    args = args[0] if args.length == 1 && args[0].is_a?(Array)
    @complex = Complex *args
  end

  def hash
    complex.hash
  end

  def ==(other)
    if other.is_a? Point
      complex == other.complex
    else
      super other
    end
  end

  def eql?(other)
    complex.eql? other.complex
  end

  def +(vector)
    raise "expected vector instead of #{vector}" if !vector.is_a? Vector

    Point(complex + vector.complex)
  end

  def to_s
    "(#{x},#{y})"
  end

  def x
    complex.real
  end

  def y
    complex.imag
  end

  def inspect
    "(#{x},#{y})"
  end

  def -(other)
    Vector(x - other.x, y - other.y)
  end

  def cartesian_neighbors
    [Point(x+1,y), Point(x,y+1), Point(x-1,y), Point(x,y-1)]
  end
end

def Point(*args)
  Point.new *args
end
