-- library of functions for the antenna wifi alignment and following tool
sys = require('luci.sys')
uci = require('uci')
config = require('jconfig')

-- debug function - prints string if debug variable is set
function debug(message, level)
    if (config.debug >= level) then
        print(message)
    end -- if debug
end -- function debug

-- sleep function
function sleep(sec)
    local stop = tonumber(os.clock() + sec);
    while (os.clock() < stop) do
    end
end -- function sleep

-- trim a string (removes trailing whitespaces)
function trim(s)
    return s:match '^%s*(.*%S)' or ''
end -- function trim

-- return true if file exists
function file_exists(name)
    -- try to open file
    local f = io.open(name, 'r')
    -- check if open was successful
    if f ~= nil then
        -- f exists
        io.close(f)
        return true
    else
        -- f is nil
        return false
    end -- if f
end -- function file_exists

-- write value to file and close it
function writeToFile(path, value)
    -- open file
    local f = io.open(path, 'w')
    -- write value
    f:write(value)
    -- close file
    f:close()
end -- function writeToFile

function readFromFile(path)
    -- open file
    local f = io.open(path, 'r')
    -- read value
    local value = f:read()
    -- close file
    f:close()

    return value
end -- function readFromFile

function gpioCreate(id, direction)
    -- set allowed directions
    local dir = { ['in'] = true, ['out'] = true }
    -- break if direction is not allowed
    if not dir[direction] then
        return false
    end -- if not dir

    -- check if GPIO pin exists already
    if not file_exists('/sys/class/gpio/gpio' .. id .. '/direction') then
        -- create GPIO pin
        writeToFile('/sys/class/gpio/export', id)
    end
    -- check if creation was successful
    if not file_exists('/sys/class/gpio/gpio' .. id .. '/direction') then
        return false
    else
        -- set direction
        writeToFile('/sys/class/gpio/gpio' .. id .. '/direction', direction)
    end
end -- function gpioCreate

function gpioWrite(id, value)
    if (readFromFile('/sys/class/gpio/gpio' .. id .. '/direction') == 'out') then
        -- check if GPIO pin exists
        if file_exists('/sys/class/gpio/gpio' .. id .. '/value') then
            -- all ok, write value
            writeToFile('/sys/class/gpio/gpio' .. id .. '/value', value)
        else
            -- break because the GPIO pin doesn't exist
            print('read failed - GPIO pin ' .. id .. ' does not exist')
        end -- if file_exists
    else
        -- break because we can only write when direction is 'out'
        print('write failed - id: ' .. id .. ' direction: ' .. readFromFile('/sys/class/gpio/gpio' .. id .. '/direction'))
        return false
    end -- if direction
end -- end gpioWrite

function gpioRead(id)
    -- check if GPIO pin exists
    if file_exists('/sys/class/gpio/gpio' .. id .. '/value') then
        value = readFromFile('/sys/class/gpio/gpio' .. id .. '/value')
    else
        -- break because the GPIO pin doesn't exist
        print('read failed - GPIO pin ' .. id .. ' does not exist')
        value = nil
    end -- if file_exists

    return value
end -- function gpioRead
