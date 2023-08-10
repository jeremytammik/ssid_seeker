require('jlib')

function initialize()
  gpioCreate(config.pin_motor_l, 'out')
  gpioWrite(config.pin_motor_l, 0)
  gpioCreate(config.pin_motor_r, 'out')
  gpioWrite(config.pin_motor_r, 0)

  gpioCreate(config.pin_switch_end, 'in')
end

function is_end_switch_on()
  return gpioRead(config.pin_switch_end) == '0'
end

function motor_stop()
  gpioWrite(config.pin_motor_l, 0)
  gpioWrite(config.pin_motor_r, 0)
end

-- step back a bit after hitting end sensor
function motor_step_back(direction)
  for i = 1, config.stepback do
    gpioWrite(direction, 1)
  end
  motor_stop()
end

function motor_step(directionforward, directionback)
  reached_end = false
  for i = 1, config.steploop do
    gpioWrite(directionforward, 1)
    if is_end_switch_on() then
      motor_stop()
      motor_step_back(directionback)
      reached_end = true
      break
    end
  end
  motor_stop()
  return not reached_end
end

function motor_step_l()
  return motor_step(config.pin_motor_l, config.pin_motor_r)
end

function motor_step_r()
  return motor_step(config.pin_motor_r, config.pin_motor_l)
end

function reset()
  while (not is_end_switch_on()) do
    gpioWrite(config.pin_motor_l, 1)
  end
  motor_stop()
  motor_step_back(config.pin_motor_r)
end

