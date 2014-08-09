local url_count = 0
local tries = 0


read_file = function(file)
    if file then
        local f = assert(io.open(file))
        local data = f:read("*all")
        f:close()
        return data
    else
        return ""
    end
end


wget.callbacks.httploop_result = function(url, err, http_stat)
  -- NEW for 2014: Slightly more verbose messages because people keep
  -- complaining that it's not moving or not working
  local status_code = http_stat["statcode"]

  url_count = url_count + 1
  io.stdout:write(url_count .. "=" .. status_code .. " " .. url["url"] .. ".  \r")
  io.stdout:flush()

  if status_code >= 500 or 
  (status_code >= 400 and status_code ~= 404) then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 2")
    
    tries = tries + 1
    
    if tries >= 5 then
        io.stdout:write("\nI give up...\n")
        io.stdout:flush()
        return wget.actions.ABORT
    else
        return wget.actions.CONTINUE
    end
  end
  
  tries = 0

  -- We're okay; sleep a bit (if we have to) and continue
  local sleep_time = 0.1 * (math.random(75, 1000) / 100.0)

  if string.match(url["host"], "cdn") or string.match(url["host"], "media") then
    -- We should be able to go fast on images since that's what a web browser does
    sleep_time = 0
  end

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end

