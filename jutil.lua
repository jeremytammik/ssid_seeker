require('jlib')

function initialize()
  gpioCreate(config.pin_motor_l, 'out')
  gpioWrite(config.pin_motor_l, 0)
  gpioCreate(config.pin_motor_r, 'out')
  gpioWrite(config.pin_motor_r, 0)

  gpioCreate(config.pin_switch_end, 'in')
end -- initialize

function is_end_switch_on()
  return gpioRead(config.pin_switch_end) == '0'
end -- switch_end

function motor_stop()
  gpioWrite(config.pin_motor_l, 0)
  gpioWrite(config.pin_motor_r, 0)
end -- motor_stop

function motor_end_switch_monitor()
  debug('> motor_end_switch_monitor', 1)
  while true do
    if is_end_switch_on() then
      motor_stop()
    end
    sleep(1)
  end
end

function motor_step(direction)
  for i = 1, config.steploop do
    gpioWrite(direction, 1)
    if is_end_switch_on() then
      motor_stop()
      break
    end
  end
  motor_stop()
end -- motor_step_r

function motor_step_l()
  motor_step(config.pin_motor_l)
end -- function motor_step_l

function motor_step_r()
  motor_step(config.pin_motor_r)
end -- function motor_step_l

function reset()
  while (not is_end_switch_on()) do
    gpioWrite(config.pin_motor_l, 1)
  end -- while switch_end
  motor_stop()
  motor_step_r()
end -- function reset

