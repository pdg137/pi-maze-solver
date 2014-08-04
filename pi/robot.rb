#!/usr/bin/env ruby

system("echo #{Process.pid} > /var/run/robot.pid")
$stdout.sync = $stderr.sync = true

require_relative 'a_star'
require_relative 'maze_solver'

a_star = AStar.new

while true
  a_star.set_leds(true,false,false)
  sleep 0.2
  a_star.set_leds(false,false,true)
  sleep 0.2
  a_star.set_leds(false,false,false)
  sleep 0.6

  sensors = [0,0,0,0,0]
  report = a_star.get_report
  if report.buttons & 1 == 1
    puts "Power button pressed - executing 'halt'..."
    system("halt")
  end

  if report.button1?
    MazeSolver.new(a_star).run
  end
end
