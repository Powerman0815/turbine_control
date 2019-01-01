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



--===== Initialization of all peripherals =====

function initPeripherals()
	--Get all peripherals
	local peripheralList = peripheral.getNames()
	for i = 1, #peripheralList do
		--Turbines
		if peripheral.getType(peripheralList[i]) == "BigReactors-Turbine" then
			t[amountTurbines] = peripheral.wrap(peripheralList[i])
			amountTurbines = amountTurbines + 1
			--Reactor
		elseif peripheral.getType(peripheralList[i]) == "BigReactors-Reactor" then
			r = peripheral.wrap(peripheralList[i])
			--Monitor & Touchpoint
		elseif peripheral.getType(peripheralList[i]) == "monitor" then
			mon = peripheral.wrap(peripheralList[i])
			touchpointLocation = peripheralList[i]
			--Capacitorbank / Energycell / Energy Core
		else
			local tmp = peripheral.wrap(peripheralList[i])
			local stat,err = pcall(function() tmp.getEnergyStored() end)
			if stat then
				v = tmp
			end
		end
	end
end


--- Start Programm -------------------------------------------------


initPeripherals()

os.execute("clear")
print("anzahl Turbinen: " .. amountTurbines)
