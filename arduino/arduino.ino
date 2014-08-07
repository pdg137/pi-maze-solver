#include <Wire.h>
#include "i2c_interface.h"
#include "motors.h"
#include "encoders.h"
#include "follow.h"
#include "buttons.h"

#define COMMAND_NONE 0
#define COMMAND_TURN_LEFT 1
#define COMMAND_TURN_RIGHT 2
#define COMMAND_TURN_BACK 3
#define COMMAND_FOLLOW 4
#define COMMAND_FOLLOW_THEN_LEFT 5
#define COMMAND_FOLLOW_THEN_RIGHT 6

struct
{
  uint8_t command_count;
  uint8_t command;
  uint32_t follow_min_distance;
  uint8_t led_state_modified;
  uint8_t led_state;
} data;


struct
{
  uint8_t command_count;
  int32_t distance;
  uint32_t error1;
  uint32_t error2;
  uint8_t button_state;
  uint8_t sensors[5];
  int16_t pos;
  uint8_t follow_state;
  uint8_t detected_left, detected_straight, detected_right, detected_end;
} report;

void setup()
{
  pinMode(13, OUTPUT);
  pinMode(18, INPUT_PULLUP);
  pinMode(15, INPUT_PULLUP);
  pinMode(14, INPUT_PULLUP);
  
  I2cInterface::setup(20, (uint8_t *)(&data), sizeof(data),
    (uint8_t *)(&report), sizeof(report));
  Motors::setup(4,5);
  Encoders::setup();
}

void check_command()
{
  uint8_t new_command=COMMAND_NONE;
  
  cli();
  if(data.command_count != report.command_count)
  {
    new_command = data.command;
  }
  sei();
  
  report.command_count = data.command_count;
  
  switch(new_command)
  {
  case COMMAND_TURN_LEFT:
    Follow::doTurn(-90);
    break;
  case COMMAND_TURN_RIGHT:
    Follow::doTurn(90);
    break;
  case COMMAND_TURN_BACK:
    Follow::doTurn(-180);
    break;
  case COMMAND_FOLLOW:
    Follow::doFollow(data.follow_min_distance);
    break;
  case COMMAND_FOLLOW_THEN_LEFT:
    Follow::doFollow(data.follow_min_distance,-45);
    break;
  case COMMAND_FOLLOW_THEN_RIGHT:
    Follow::doFollow(data.follow_min_distance,45);
    break;
  }
}

void loop()
{
  Encoders::update();
  Buttons::update();    
  Follow::update();
  
  report.button_state = (Buttons::button0) +
    (Buttons::button1 * 2) +
    (Buttons::button2 * 4);
  report.distance = Encoders::distance;
  report.error1 = Encoders::error1;
  report.error2 = Encoders::error2;
 
   uint8_t i;
   for(i=0;i<5;i++)
     report.sensors[i] = Follow::sensors[i];
   report.pos = Follow::pos;
   report.follow_state = Follow::state;
   report.detected_left = Follow::detected_left;
   report.detected_straight = Follow::detected_straight;
   report.detected_right = Follow::detected_right;
   report.detected_end = Follow::detected_end;
 
  if(data.led_state & 1) RXLED1;
  else RXLED0;
  
  if(data.led_state & 2) digitalWrite(13, HIGH);
  else digitalWrite(13, LOW);
  
  if(data.led_state & 4) TXLED1;
  else TXLED0;
  
  check_command();
}

