-- Reactor- and Turbine control by Powerman0815 --
-- Version 1.0 --
-- Start program --

--========== Globale Variabeln für alle Bereiche ==========


--All options

rodLevel = 0

turbineTargetSpeed = 0
targetSteam = 0
getSteam = 0

--Peripherals
mon = "" --Monitor
r = "" --Reactor
v = "" --Energy Storage
t = {} --Turbines

--Total count of all turbines
amountTurbines = 0
--TouchpointLocation (same as the monitor)
touchpointLocation = {}

local component = require("component")
local keyboard = require("keyboard")
local event = require("event")

gpu = component.gpu -- get primary gpu component
--===== Initialization of all peripherals =====

function initPeripherals()
	--Get all peripherals

	for add, typ in component.list() do
		if typ == "br_turbine" then
			t[amountTurbines] = component.proxy(add)
			amountTurbines = amountTurbines + 1
		elseif typ == "br_reactor" then
			r = component.proxy(add)
			--Monitor & Touchpoint
		elseif typ == "screen" then
			mon = component.proxy(add)
			--touchpointLocation = peripheralList[i]
			--Capacitorbank / Energycell / Energy Core
		elseif typ == "energy_device" then
			v = component.proxy(add)
			print (v.getEnergyStored())
			print (v.getMaxEnergyStored())
		end
	end
end

--- funktionen -----------------------------------------------------


function setRod(setrodV)
	rodLevel = rodLevel + setrodV
	if rodLevel>100 then
		rodLevel= 100
	elseif rodLevel<0 then
		rodLevel = 0
	end

	r.setAllControllRodLevels(rodLevel)
end

function getSteam()
	return r.getHotFluidProducedLastTick()
end

function printStaticControlText()
  gpu.set(10,10, "Rod Level")
  gpu.set(10,13, "Dampferzeugung")
end

function aktAnz()
	gpu.set(30,10,tostring(rodLevel))
	gpu.set(30,13,getSteam())
end

--- Start Programm -------------------------------------------------



initPeripherals()

os.execute("clear")
printStaticControlText()

while event.pull(0.1, "interrupted") == nil do
	aktAnz()
  local event, address, arg1, arg2, arg3 = event.pull(1)
  if type(address) == "string" and component.isPrimary(address) then
    if event == "key_down" and arg2 == keyboard.keys.q then
      os.exit()
    elseif event == "key_down" and arg2 == keyboard.keys.up then
			setRod(1)
		elseif event == "key_down" and arg2 == keyboard.keys.down then
			setRod(-1)
		end
	end
end
