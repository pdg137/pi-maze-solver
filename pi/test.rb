require_relative 'lib/a_star'

a_star = AStar.new

while true
  a_star.set_leds(true,false,false)
  sleep 0.2
  a_star.set_leds(false,false,true)
  sleep 0.2

  sensors = [0,0,0,0,0]
  report = a_star.get_report
  if report.button0?
    puts "Power button pressed - executing 'halt'..."
    system("halt")
  end

  if report.button1?
    a_star.send_command(5,300)
  end

  if report.button2?
    a_star.send_command(6,300)
  end
end
