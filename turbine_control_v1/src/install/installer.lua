print("installer.lua")

local fs = require("filesystem")
local internet = require("internet")
local dir = ""
local relPath = "turbine-controller/"
branch = "master"
relUrl = "https://raw.githubusercontent.com/Powerman0815/turbine_control/"..branch.."/turbine_control_v1/src/"


local function getFile(filename)
  filename = dir .."/".. filename
	local url = relUrl..filename
  local f, reason = io.open(relPath..filename, "w")
  if not f then
    io.stderr:write("Failed opening file for writing: " .. reason)
    return
  end

  io.write("Downloading from quelle... ")

  local result, response = pcall(internet.request, url)
  if result then
    io.write("success.\n")
    for chunk in response do
      f:write(chunk)
    end

    f:close()
    io.write("Saved data to " .. filename .. "\n")
  else
    io.write("failed.\n")
    f:close()
    fs.remove(relPath..filename)
    io.stderr:write("HTTP request failed: " .. response .. "\n")
  end
end


--Clears the terminal
function clearTerm()
	shell.execute("clear")
	term.setCursor(1,1)
end

function mkDir (dir)
      fs.makeDirectory("home/"..relPath..dir)
end


-- Dir Start
dir = "start"
  mkDir(dir)
    getFile("start.lua")
