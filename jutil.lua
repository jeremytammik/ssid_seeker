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

function motor_step_r()
  gpioWrite(config.pin_motor_r, 1)
  sleep(config.step)
  motor_stop()
end -- motor_step_r

function motor_step_l()
  gpioWrite(config.pin_motor_l, 1)
  sleep(config.step)
  motor_stop()
end -- function motor_step_l

function reset()
  while (not is_end_switch_on()) do
    gpioWrite(config.pin_motor_l, 1)
  end -- while switch_end
  motor_stop()
  motor_step_r()
end -- function reset

function get_ssids(ssids)
  -- get scan result from wifi interface
  iWInfo = sys.wifi.getiwinfo(config.ifName)
  if table.getn(iWInfo) == 0 then
    iWInfo = sys.wifi.getiwinfo("wlan0")
  end

  -- check if scanlist has any values
  if iWInfo.scanlist then
    -- iterate over all scan results and store each in variable cell
    for i, cell in ipairs(iWInfo.scanlist) do
      -- check if SSID exists
      if cell.ssid then
        -- check if SSID exists in ssids list
        if ssids[cell.ssid] then
          -- check if stored quality is lower than current quality value
          if ssids[cell.ssid] < cell.quality then
            -- if lower then save
            ssids[cell.ssid] = cell.quality
          end -- if quality
        else
          -- save SSID for the first time
          ssids[cell.ssid] = cell.quality
        end -- if ssids
      end -- if SSID
    end -- for cell
  end -- if scanlist

  debug('<<< function get_ssids', 2)
  return (ssids)
end -- function get_ssids

