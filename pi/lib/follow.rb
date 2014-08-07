require 'response_state'

class Follow < ResponseState::Service
  def initialize(a_star, follow_min_distance, smooth_turn)
    @a_star = a_star
    @follow_min_distance = follow_min_distance
    @smooth_turn = smooth_turn
  end

  def call(&block)
    @a_star.send_follow_command(@follow_min_distance, @smooth_turn)

    until @a_star.get_report.follow_state == 0 ||
        @a_star.get_report.follow_state == 4
      sleep(0.01)
    end

    report = @a_star.get_report
    exits = report.exits
    state = if report.end == 1
              :end
            else
              :intersection
            end

    # blank out exits and status on smooth_turn
    if @smooth_turn
      exits = []
      state = :smooth_turn_done
    end

    context = { distance: report.distance, exits: exits }

    if report.button2?
      state = :button
    end

    yield send_state(state, '', context)
  end
end
