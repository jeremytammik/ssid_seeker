require('jlib')

function connect_to_network(ssid, password)
  local wlCursor = luci.model.uci.cursor_state()
  local bestSignalStrength = 0
  local stepOfBestSignal = 0
  local currentStep = 0
  local signalStrength = 0

  signalStrength = get_signal_strength(ssid)
  bestSignalStrength = signalStrength

  continue_scan = true
  while continue_scan do
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

    continue_scan = motor_step_r()
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

