return {
  log = (function(s) return function() print(s) end end),
  warn = (function(s) return function() io.stderr:write(tostring(s) .. "\n") end end),
  error = (function(s) return function() io.stderr:write(tostring(s) .. "\n") end end),
  info = (function(s) return function() print(s) end end),
  debug = (function(s) return function() print(s) end end),
  time = (function(_s) return function() error("Sorry, console timers aren't implemented yet") end end),
  timeLog = (function(_s) return function() error("Sorry, console timers aren't implemented yet") end end),
  timeEnd = (function(_s) return function() error("Sorry, console timers aren't implemented yet") end end),
  clear = (function() io.write("\027[H\027[2J") end)
}
