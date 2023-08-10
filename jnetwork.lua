require('jlib')

function connect_to_network(ssid, password)
  local wlCursor = luci.model.uci.cursor_state()
  local bestSignalStrength = 0
  local stepOfBestSignal = 0
  local currentStep = 0
  local signalStrength = 0

  signalStrength = get_signal_strength(ssid)
  bestSignalStrength = signalStrength

  while not is_end_switch_on() do
    signalStrength = get_signal_strength(ssid)
    if signalStrength >= bestSignalStrength then
      bestSignalStrength = signalStrength
      stepOfBestSignal = currentStep
    end
    print("> Step forward")
    print("Current quality: " .. signalStrength)
    print("Best quality: " .. bestSignalStrength)
    print("Current step: " .. currentStep)
    print("Best step: " .. stepOfBestSignal)

    if not is_end_switch_on() then
      motor_step_r()
    end
    currentStep = currentStep + 1
  end

  while(stepOfBestSignal ~= currentStep) do
    print("> Step back")
    motor_step_l()
    currentStep = currentStep - 1
  end

  if bestSignalStrength > 0 then
    local networkDetails = get_network_details(ssid)
    local encryption = "none"

    if networkDetails.encryption.wep then
      encryption = "wep"
    elseif networkDetails.encryption.wpa == 1 then
      encryption = "psk"
    elseif networkDetails.encryption.wpa >= 2 then
      encryption = "psk2"
    end

    wlCursor:set("wireless", "sta", "ssid", networkDetails.ssid)
    wlCursor:set("wireless", "sta", "key", password)
    wlCursor:set("wireless", "sta", "bssid", networkDetails.bssid)
    wlCursor:set("wireless", "sta", "channel", networkDetails.channel)
    wlCursor:set("wireless", "sta", "encryption", encryption)
    wlCursor:commit("wireless")

    print("Done.")
  else
    print("Network not found.")
  end
end

function get_signal_strength(ssidToSearch)

  iWInfo = sys.wifi.getiwinfo(config.ifName)
  if table.getn(iWInfo) == 0 then
    iWInfo = sys.wifi.getiwinfo("wlan0")
  end
  local signalStrength = 0

  if iWInfo.scanlist then
    for i, cell in ipairs(iWInfo.scanlist) do
      if cell.ssid == ssidToSearch then
        signalStrength = cell.quality
      end
    end
  end

  return (tonumber(signalStrength))
end -- function get_signal_strength

function get_network_details(ssidToSearch)
  iWInfo = sys.wifi.getiwinfo(config.ifName)
  if table.getn(iWInfo) == 0 then
    iWInfo = sys.wifi.getiwinfo("wlan0")
  end
  local network

  if iWInfo.scanlist then
    for i, cell in ipairs(iWInfo.scanlist) do
      if cell.ssid == ssidToSearch then
        network = cell
      end
    end
  end

  return (network)
end -- function get_network_details
