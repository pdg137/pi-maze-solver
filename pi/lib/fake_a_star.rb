require 'response_state'

class FakeAStar
  class OffLineException < Exception
  end

  attr_reader :maze, :pos, :vec

  def initialize(map)
    @maze = GriddedMaze.from_s map
  end

  def goto(point, vector)
    @pos = point
    @vec = vector
  end

  def turn(dir)
    response = ResponseState::Response.new(:done)
    @vec = @vec.turn dir
    yield response
  end

  def follow(follow_min_distance)
    original_pos = @pos
    exits = nil
    distance = 0

    # randomly screw up sometimes on straightaways over 4 to make sure we can recover
    if rand < 0.2 && follow_min_distance > 7000
      follow_min_distance -= 1800
    end

    while (!exits || exits == [:straight, :back]) || distance < follow_min_distance
      new_pos = @pos + @vec

      if !@maze.connections[@pos].include? new_pos
        raise OffLineException.new
      end

      @pos = new_pos
      distance = (@pos - original_pos).length * 300 * 6 + (rand(60) - 30)

      # get exits sorted in leftmost order
      exits = @maze.connections[@pos].map do |neighbor|
        @vec.dir_to(neighbor - @pos)
      end.sort_by do |dir|
        [:left,:straight,:right,:back].index dir
      end
    end

    # the robot seems to detect exits on an end spot
    # this will force us to ignore them
    if maze.end == @pos
      exits = [:left,:straight,:right,:back]
    end

    status = if maze.end == @pos
               :end
             else
               :intersection
             end


    response = ResponseState::Response.new(status,
                                           "",
                                           {exits: exits, distance: distance}
                                           )
    yield response
  end
end
