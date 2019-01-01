API = require("buttonAPI")
local filesystem = require("filesystem")
local component = require("component")
local keyboard = require("keyboard")
local event = require("event")

term = require("term")
sides = require("sides")


local colors = { blue = 0x4286F4, purple = 0xB673d6, red = 0xC14141, green = 0xDA841, black = 0x000000, white = 0xFFFFFF, grey = 0x47494C, lightGrey = 0xBBBBBB}

term.clear()
if ( component.isAvailable("redstone")) then
	rs = component.redstone
end

init = true
statusDiesel = 5

gpu = component.gpu -- get primary gpu component
local w, h = gpu.getResolution()
local teilung = 4
local posGraf = 20
pos = posGraf
	
local sections = {}
local graphs = {}
local infos = {}




-- defninitions
--diesel["stats"] = {}


-- defninitions
reactor["stats"] = {}
local running = true
local maxRF = 0
local reactorRodsLevel = {}
local currentRodLevel = 0
local currentRf = 0
local currentRfTick = 0
local currenFuel = 0

local minPowerRod = 0
local maxPowerRod = 100





function setSections()
--  sections["graph"] = { x = 5, y = 3, width = 78, height= 33, title = "  INFOS  "}
--  sections["controls"] = { x = 88, y = 3, width = 40, height = 20, title = "  CONTROLS  "}
--  sections["info"] = { x = 88, y = 26, width = 40, height= 10, title = "  NUMBERS  "}
sections["DieselGenerator"] = { x = 1, y = 1, width = 45, height= 10, title = "  Diesel  "}
sections["Refinery"] = { x = 52, y = 1, width = 65, height= 8, title = "  Refinery  "}
--sections["Batterie"] = { x = 52, y = 10, width = 65, height= 10, title = "  Batterie  "}

end	

function setGraphs()
--  graphs["tick"] = { x = 8, y = 6, width = 73, height= 8, title = "ENERGY LAST TICK"}
--  graphs["stored"] = { x = 8, y = 16, width = 73, height = 8, title = "ENERGY STORED"}
--  graphs["rods"] = { x = 8, y = 26, width = 73, height= 8, title = "CONTROL RODS LEVEL"}
end

function setInfos()
  -- infos["labelDie"] = { x = 3, y = 3, width = 40, height= 1, title = "Fuel Type    : ", unit = " "}
  -- infos["amountDie"] = { x = 3, y = 4, width = 40, height= 1, title = "Amount       : ", unit = " "}
  -- infos["capaDie"] = { x = 3, y = 5, width = 40, height= 1, title = "Tank Cap.    : ", unit = " "}
  -- infos["percDie"] = { x = 3, y = 6, width = 40, height= 1, title = "Full         : ", unit = " %"}
 
  -- infos["labelRef1"] = { x = 55, y = 3, width = 10, height= 1, title = "Fuel Type    : ", unit = " "}
  -- infos["labelRef2"] = { x = 85, y = 3, width = 10, height= 1, title = " ", unit = " "}
  -- infos["labelRef3"] = { x = 105, y = 3, width = 10, height= 1, title = " ", unit = " "}

  -- infos["amountRef1"] = { x = 55, y = 4, width = 10, height= 1, title = "Amount       : ", unit = " "}
  -- infos["amountRef2"] = { x = 85, y = 4, width = 10, height= 1, title = " ", unit = " "}
  -- infos["amountRef3"] = { x = 105, y = 4, width = 10, height= 1, title = " ", unit = " "}

  -- infos["capaRef1"] = { x = 55, y = 5, width = 10, height= 1, title = "Tank Cap.    : ", unit = " "}
  -- infos["capaRef2"] = { x = 85, y = 5, width = 10, height= 1, title = " ", unit = " "}
  -- infos["capaRef3"] = { x = 105, y = 5, width = 10, height= 1, title = " ", unit = " "}


  -- infos["percRef1"] = { x = 55, y = 6, width = 10, height= 1, title = "Full         : ", unit = " %"}
  -- infos["percRef2"] = { x = 85, y = 6, width = 10, height= 1, title = " ", unit = " %"}
  -- infos["percRef3"] = { x = 105, y = 6, width = 10, height= 1, title = " ", unit = " %"}
  
  
--  infos["battEnergy"] = { x = 55, y = 12, width = 40, height= 1, title = "Energie      : ", unit = " RF"}

--  infos["tick"] = { x = 92, y = 28, width = 73, height= 1, title = "RF PER TICK : ", unit = " RF"}
--  infos["stored"] = { x = 92, y = 30, width = 73, height = 1, title = "ENERGY STORED : ", unit = " RF"}
--  infos["rods"] = { x = 92, y = 32, width = 73, height= 1, title = "CONTROL ROD LEVEL : ", unit = "%"}
--  infos["fuel"] = { x = 92, y = 34, width = 73, height= 1, title = "FUEL USAGE : ", unit = " Mb/t"}
end

function setButtons()
--  API.setTable("OFF", allOff, 144, 47, 149, 49,"OFF", {on = colors.red, off = colors.red})


--  API.setTable("ON", powerOn, 91, 5, 106, 7,"ON", {on = colors.green, off = colors.green})
--  API.setTable("OFF", powerOff, 109, 5, 125, 7,"OFF", {on = colors.red, off = colors.red})

--  API.setTable("lowerMinLimit", lowerMinLimit, 91, 15, 106, 17,"-10", {on = colors.blue, off = colors.blue})
--  API.setTable("lowerMaxLimit", lowerMaxLimit, 109, 15, 125, 17,"-10", {on = colors.purple, off = colors.purple})

--  API.setTable("augmentMinLimit", augmentMinLimit, 91, 19, 106, 21,"+10", {on = colors.blue, off = colors.blue})
--  API.setTable("augmentMaxLimit", augmentMaxLimit, 109, 19, 125, 21,"+10", {on = colors.purple, off = colors.purple})

end

function printBorders(sectionName)
  local s = sections[sectionName]

  -- set border
  gpu.setBackground(colors.grey)
  gpu.fill(s.x, s.y, s.width, 1, " ")
  gpu.fill(s.x, s.y, 1, s.height, " ")
  gpu.fill(s.x, s.y + s.height, s.width, 1, " ")
  gpu.fill(s.x + s.width, s.y, 1, s.height + 1, " ")

  -- set title
  gpu.setBackground(colors.black)
  gpu.set(s.x + 2, s.y, s.title)
end

function printGraphs(graphName)
  local g = graphs[graphName]

  -- set graph
  gpu.setBackground(colors.lightGrey)
  gpu.fill(g.x, g.y, g.width, g.height, " ")

  -- set title
  gpu.setBackground(colors.black)
  gpu.set(g.x, g.y - 1, g.title)
end


function printInfos(infoName)
  local maxLength = 15
  local i = infos[infoName]
  local spaces = string.rep(" ", maxLength - string.len(diesel.stats[infoName] .. i.unit))
  gpu.set(i.x, i.y , i.title .. diesel.stats[infoName] .. i.unit .. spaces)
end

function printStaticControlText()


  gpu.setForeground(colors.blue)
--  gpu.set(97,12, w)
  gpu.setForeground(colors.purple)
--  gpu.set(116,12, h)
  gpu.setForeground(colors.white)
  gpu.set(138,50, "'q' für EXIT")
  -- gpu.set(107,13, "--")
  
  
  
end


function iif ( cond , T , F )
    if cond then return T else return F end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function grafik(strg,wert,col)
	wert = wert*w
	gpu.setForeground(colors.white)
	gpu.setBackground(colors.black)

	gpu.fill(1, pos, w, 3, " ") -- clears the screen
	
	gpu.setBackground(col)
	gpu.fill(1, pos, wert, 3, " ") -- clears the screen
	
	term.setCursor(5,pos+1)
	print(strg)
	gpu.setBackground(0x000000)
	
	pos= pos+4
end






function allOff()

 	gpu.setForeground(0xFFFFFF)
	gpu.setBackground(0x000000)
	
	

os.exit()
end
	
function startup()
	callDiesel()
	callRef()
  -- getInfoFromFile()
  -- if versionType == "NEW" then
    -- getInfoFromReactor()
  -- else
    -- getInfoFromReactorOLD()
--  end


  setSections()
  setGraphs()
  setInfos()
  setButtons()
  -- if DEBUG == true then
    -- debugInfos()
    -- printDebug()
  -- end

  for name, data in pairs(sections) do
    printBorders(name)
  end
  for name, data in pairs(graphs) do
    printGraphs(name)
  end
  for name, data in pairs(infos) do
    printInfos(name)
  end
  printStaticControlText()


end	
	




	
	
	
--	require "diesel"
--	require "refinery"


	
if ( not( component.isAvailable("energy_device"))) then
	print("keine energiezelle vorhanden")
	
	os.exit()
end
if (not( component.isAvailable("ie_diesel_generator"))) then	
	print("kein Dieselagregat vorhanden")
	
	os.exit()
end


function calculate()	

batt = component.energy_device

	pos = posGraf
	term.setCursor(1,10)

--diesel.stats["battEnergy"] = batt.getEnergyStored()

--	print("Energie      : "..batt.getEnergyStored().." RF                   ")
	
	aktBatt = round(((batt.getEnergyStored() / batt.getMaxEnergyStored())*100),2)
--	print("Energie  %   : "..aktBatt.."                    ")
	
	
	grafbatt = (batt.getEnergyStored() / batt.getMaxEnergyStored())
	grafik("Energie",grafbatt,0x0000FF)
	
	callDiesel()  	---Diesel aufrufen
	callRef()		---Refinery aufrufen
	
	
	
	init = false

end

	
--startup()	
--API.screen()	
	
event.listen("touch", API.checkxy)

while event.pull(0.1, "interrupted") == nil do
 
--  calculateAdjustRodsLevel()
--  draw()
	calculate()
  local event, address, arg1, arg2, arg3 = event.pull(1)
  if type(address) == "string" and component.isPrimary(address) then
    if event == "key_down" and arg2 == keyboard.keys.q then		
		term.clear()
		print("diesel STOPP")
		
      os.exit()
    end
  end
end	




