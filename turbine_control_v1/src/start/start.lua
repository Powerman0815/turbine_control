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
term = require("term")
gpu = component.gpu -- get primary gpu component

local colors = { blue = 0x4286F4, purple = 0xB673d6, red = 0xC14141, green = 0xDA841,
  black = 0x000000, white = 0xFFFFFF, grey = 0x47494C, lightGrey = 0xBBBBBB}

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
	amountTurbines = amountTurbines - 1
end

--- funktionen -----------------------------------------------------
function monClear()
	local w, h = gpu.getResolution()
	gpu.fill(1, 1, w, h, " ") -- clears the screen
end
function allTurbinesOn()
	for i = 0 ,amountTurbines do
		t[i].setActive(true)
		t[i].setInductorEngaged(true)
		t[i].setFluidFlowRateMax(2000) -- targetSteam
	end
end

function getTo99c()
    gpu.setBackground(colors.black)
--    gpu.setTextColor(textColor)
    monClear()
    gpu.set(1, 1,"Bringe Reaktor unter 99 Grad...")

    --Disables reactor and turbines
    r.setActive(false)
    allTurbinesOn()

    --Temperature variables
    local fTemp = r.getFuelTemperature()
    local cTemp = r.getCasingTemperature()
    local isNotBelow = true

    --Wait until both values are below 99
    while isNotBelow do
        term.setCursor(1, 2)
        print("CoreTemp: " .. fTemp .. "      ")
        print("CasingTemp: " .. cTemp .. "      ")

        fTemp = r.getFuelTemperature()
        cTemp = r.getCasingTemperature()

        if fTemp < 99 then
            if cTemp < 99 then
                isNotBelow = false
            end
        end

        os.sleep(1)
    end --while
end


function setRod(setrodV)
	rodLevel = rodLevel + setrodV
	if rodLevel>100 then
		rodLevel= 100
	elseif rodLevel<0 then
		rodLevel = 0
	end

	for key,value in pairs (r.getControlRodsLevels()) do
		r.setControlRodLevel(key,rodLevel)
	end


--	r.setAllControllRodLevels(rodLevel)
end

function getSteam()
	return r.getHotFluidProducedLastTick()
end

function getTemp()
	return r.getFuelTemperature()
end

function printStaticControlText()
  gpu.set(10,10, "Rod Level")
  gpu.set(10,13, "Dampferzeugung")
	gpu.set(10,16, "Temperatur")
end

function aktAnz()
	gpu.set(30,10,tostring(rodLevel))
	gpu.set(30,13,tostring(getSteam()))
	gpu.set(30,16,tostring(getTemp()))
end

--- Start Programm -------------------------------------------------



initPeripherals()

os.execute("clear")
printStaticControlText()

getTo99c()



while event.pull(0.1, "interrupted") == nil do
	aktAnz()
  local event, address, arg1, arg2, arg3 = event.pull(1)
  if type(address) == "string" and component.isPrimary(address) then
    if event == "key_down" and arg2 == keyboard.keys.q then
      os.exit()
			break
    elseif event == "key_down" and arg2 == keyboard.keys.up then
			setRod(1)
		elseif event == "key_down" and arg2 == keyboard.keys.down then
			setRod(-1)
		end
	end
end
