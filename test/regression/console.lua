-- Regression guard for the Lua 5.1 FFI of Effect.Console.
--
--   #76 error :: String -> Effect Unit maps to console.error -> stderr in Node;
--       the Lua FFI routed it through print (stdout). Now io.stderr:write.
--   #77 warn -> console.warn -> stderr, likewise (was print/stdout).
-- log/info/debug correctly stay on stdout (console.log/info/debug all do).
--
-- The FFI reads `print` / `io.stderr` as globals at call time, so we swap them
-- around each call to observe which stream a message lands on.
-- Run from the repo root: `lua test/regression/console.lua`.
local C = dofile("src/Effect/Console.lua")

local failures = 0
local function check(name, cond, detail)
  if cond then
    print("ok   - " .. name)
  else
    failures = failures + 1
    print("FAIL - " .. name .. ": " .. tostring(detail))
  end
end

-- Run `thunk` capturing what it sends to stdout (via print) and stderr.
local function capture(thunk)
  local out, err = {}, {}
  local realPrint, realStderr = print, io.stderr
  print = function(...) out[#out + 1] = table.concat({...}, "\t") end
  io.stderr = {write = function(_, s) err[#err + 1] = s end}
  local ok, e = pcall(thunk)
  print, io.stderr = realPrint, realStderr
  if not ok then error(e) end
  return out, err
end

do
  local out, err = capture(function() C.error("err-msg")() end)
  check("error writes 'err-msg\\n' to stderr", #err == 1 and err[1] == "err-msg\n", "stderr=" .. table.concat(err))
  check("error does not write to stdout", #out == 0, "stdout=" .. table.concat(out, ","))
end

do
  local out, err = capture(function() C.warn("warn-msg")() end)
  check("warn writes 'warn-msg\\n' to stderr", #err == 1 and err[1] == "warn-msg\n", "stderr=" .. table.concat(err))
  check("warn does not write to stdout", #out == 0, "stdout=" .. table.concat(out, ","))
end

do
  local out, err = capture(function() C.log("log-msg")() end)
  check("log writes to stdout", #out == 1 and out[1] == "log-msg", "stdout=" .. table.concat(out, ","))
  check("log does not write to stderr", #err == 0, "stderr=" .. table.concat(err))
end

if failures > 0 then error(failures .. " regression check(s) failed") end
print("purescript-lua-console: all FFI regression checks passed")
