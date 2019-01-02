-- Reactor- and Turbine control by Powerman0815 --
-- Version 1.0 --
-- Start program --

--========== Globale Variabeln für alle Bereiche ==========


--All options

rodLevel = 0

turbineTargetSpeed = 0
targetSteam = 0

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

--===== Initialization of all peripherals =====

function initPeripherals()
	--Get all peripherals

	for add, typ in component.list() do
		if typ == "br_turbine" then
			t[amountTurbines] = component.methods(add)
			amountTurbines = amountTurbines + 1
		elseif typ == "br_reactor" then
			r = component.methods(add)
			--Monitor & Touchpoint
		elseif typ == "screen" then
			mon = component.methods(add)
			--touchpointLocation = peripheralList[i]
			--Capacitorbank / Energycell / Energy Core
		elseif typ == "energy_device" then
			v = component.methods(add)
			print (v.getEnergyStored)
		end
	end
end


--- Start Programm -------------------------------------------------


initPeripherals()

os.execute("clear")
print("anzahl Turbinen: " .. amountTurbines)
