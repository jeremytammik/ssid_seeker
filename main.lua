require('jutil')
require('jnetwork')

local inspect = require('inspect')
local wlCursor = luci.model.uci.cursor_state()
local ssids = {}

debug('> initialize', 1)
initialize()

-- apparently, the router does not support multi-threading
--local endSwitchThread = coroutine.create(motor_end_switch_monitor)
--coroutine.resume(endSwitchThread)

while (true) do
  print("")
  print("---Current/Last config---")
  if wlCursor:get("wireless", "sta", "ssid") ~= nil then
    print("SSID: " .. wlCursor:get("wireless", "sta", "ssid"))
    print("Password: " .. wlCursor:get("wireless", "sta", "key"))
  else
    print("Not configured!")
  end
  print("")
  print("1. Scan for available networks")
  print("2. Connect to network with SSID and password")
  print("3. Exit")

  local option = io.read()

  if option == "1" then
    debug('> reset antenna', 1)
    reset()

    debug('> start scanning', 1)
    while (not is_end_switch_on()) do
      motor_step_r()
      ssids = get_ssids(ssids)
      debug('> next iteration', 1)
    end
    motor_step_l()
    print(inspect(ssids))

  elseif option == "2" then
    debug('> reset antenna', 1)
    reset()

    print("Enter SSID: ")
    ssid = io.read()

    print("Enter Password: ")
    password = io.read()

    connect_to_network(ssid, password)
  else
  break;
end
end
