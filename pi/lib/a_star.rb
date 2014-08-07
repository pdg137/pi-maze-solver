require 'i2c'
require_relative 'a_star_report'
require_relative 'follow'
require_relative 'turn'

class AStar
  attr_reader :command_count

  def initialize
    @i2c = I2C.create('/dev/i2c-1')
    @command_count = 0
  end

  def send_command(command)
    @command_count += 1
    @i2c.write(20, [0,@command_count,command].pack("CCC"))

    while get_report.command_count != command_count
      sleep(0.01)
    end
  end

  def turn_left
    send_command(1)
  end

  def turn_right
    send_command(2)
  end

  def turn_back
    send_command(3)
  end

  def send_follow_command
    send_command(4)
  end

  def get_raw_report
    return @i2c.read(20,26).unpack("ClLLCCCCCCsccccc")
  end

  def get_report
    report = AStarReport.new
    (report.command_count,
     report.distance, report.errors1, report.errors2, report.buttons,
     report.sensors[0], report.sensors[1], report.sensors[2],
     report.sensors[3], report.sensors[4],
     report.pos, report.follow_state,
     report.left, report.straight, report.right,
     report.end) = get_raw_report
    report
  end

  def set_leds(red,yellow,green)
    led = (red ? 1 : 0) +
      (yellow ? 2 : 0 ) +
      (green ? 4 : 0)
    @i2c.write(20, [2,1,led].pack("CCC"))
  end

  def follow(&block)
    return Follow.new(self).call(&block)
  end

  def turn(dir, &block)
    Turn.new(self, dir).call(&block)
  end
end
