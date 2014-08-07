class TurningPathFollower
  def initialize(unit, limit)
    @unit = unit
    @limit = limit
  end

  def compute(turning_path)
    groups = []

    turning_path.slice_before { |turn|
      [:left,:right,:back].include? turn
    }.
      each do |turn_group|

      until turn_group.nil?
        current = turn_group[0..5]
        turn_group = turn_group[6..-1]

        # e.g. [:straight, :straight] [:none, :none]
        # -> [:straight], [:straight, :none, :none]
        while turn_group != nil && turn_group[0] == :none
          turn_group.unshift current.pop
        end

        turn_group = nil if turn_group == []

        groups << [current[0], @unit*(current.length-1) + @limit]
      end
    end

    # append the next turn
    groups.each_index do |i|
      next_turn = if groups[i+1]
                    groups[i+1][0]
                  else
                    nil
                  end
      if next_turn == :back || next_turn == :straight
        next_turn = nil
      end

      yield groups[i][0], groups[i][1], next_turn
    end
  end
end

