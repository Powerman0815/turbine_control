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
---- Config----------------
mainMenu = true,
rodLevel = 0,
targetSpeed = 2000,
overallMode = "auto",
reactorOffAt = 80,
backgroundColor = 128,
reactorOnAt = 50,
targetSteam = 2000,
turbineTargetSpeed = 1820,
version = "2.6-release",
textColor = 1,
program = "turbine",
turbineOnOff = "off",
lang = "de",


-----End Config------
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

function allTurbinesOff()
    for i = 0, amountTurbines, 1 do
        t[i].setInductorEngaged(false)
        t[i].setFluidFlowRateMax(0)
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


function findOptimalFuelRodLevel()

    --Load config?
--    if not (math.floor(rodLevel) == 0) then
--        r.setAllControlRodLevels(rodLevel)

--    else
        --Get reactor below 99c
        getTo99c()

        --Enable reactor + turbines
        r.setActive(true)
        allTurbinesOn()

        --Calculation variables
        local controlRodLevel = 99
        local diff = 0
        local targetSteamOutput = targetSteam * (amountTurbines + 1)
        local targetLevel = 99

        --Display
--        term.setBackgroundColor(backgroundColor)
--        mon.setTextColor(textColor)
        monClear()

        print("TargetSteam: " .. targetSteamOutput)

            gpu.set(1, 1,"Finde optimales FuelRod Level...")
            gpu.set(1, 3,"Berechne Level...")
            gpu.set(1, 5,"Gesuchter Steam-Output: " .. (input.formatNumber(math.floor(targetSteamOutput))) .. "mb/t")

        --Calculate Level based on 2 values
        local failCounter = 0
        while true do
            r.setAllControlRodLevels(controlRodLevel)
            os.sleep(2)
            local steamOutput1 = r.getHotFluidProducedLastTick()
            print("SO1: " .. steamOutput1)
            r.setAllControlRodLevels(controlRodLevel - 1)
            os.sleep(5)
            local steamOutput2 = r.getHotFluidProducedLastTick()
            print("SO2: " .. steamOutput2)
            diff = steamOutput2 - steamOutput1
            print("Diff: " .. diff)

            targetLevel = 100 - math.floor(targetSteamOutput / diff)
            print("Target: " .. targetLevel)

            --Check target level
            if targetLevel < 0 or targetLevel == "-inf" then

                --Calculation failed 3 times?
                if failCounter > 2 then
                    gpu.setBackgroundColor(colors.black)
                    monClear()
                    gpu.setTextColor(colors.red)
                    gpu.set(1, 1,"RodLevel-Berechnung fehlgeschlagen!")
                    gpu.set(1, 2,"Berechnung waere < 0!")
                    gpu.set(1, 3,"Bitte Steam/Wasser-Input pruefen!")

                    --Disable reactor and turbines
                    r.setActive(false)
                    allTurbinesOff()
                    for i = 1, amountTurbines do
                        t[i].setActive(false)
                    end


                    term.clear()
                    term.setCursor(1, 1)
                    print("Target RodLevel: " .. targetLevel)
                    error("Failed to calculate RodLevel!")

                else
                    failCounter = failCounter + 1
                    os.sleep(2)
                end

                print("FailCounter: " .. failCounter)

            else
                break
            end
        end

        --RodLevel calculation successful
        print("RodLevel calculation successful!")
        r.setAllControlRodLevels(targetLevel)
        controlRodLevel = targetLevel

        --Find precise level
        while true do
            os.sleep(5)
            local steamOutput = r.getHotFluidProducedLastTick()

            gpu.set(1, 3,"FuelRod Level: " .. controlRodLevel .. "  ")
						gpu.set(1, 6,"Aktueller Steam-Output: " .. (input.formatNumber(steamOutput)) .. "mb/t    ")

            --Level too big
            if steamOutput < targetSteamOutput then
                controlRodLevel = controlRodLevel - 1
                r.setAllControlRodLevels(controlRodLevel)

            else
                r.setAllControlRodLevels(controlRodLevel)
                rodLevel = controlRodLevel
--                saveOptionFile()
                print("Target RodLevel: " .. controlRodLevel)
                os.sleep(2)
                break
            end --else
        end --while
--    end --else
end
--- Start Programm -------------------------------------------------



initPeripherals()

os.execute("clear")
printStaticControlText()

--getTo99c()
findOptimalFuelRodLevel()



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
