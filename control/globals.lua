empireG = {}
empireG.debug = 2												-- Debug 1 = level 0. Debug 2 = level 0 + args. Debug 3 = level 1...
																				-- Debug Level 0 = Called, 1 = Called often, 2 = Called periodically
empireG.iMap = require("data/entityToItemMap.lua")

empireG.worldMapTiles = {}							-- Key is coordinates, so "1,4", "-1,-19"...
empireG.surfaces = {}										-- Key is surface name, so "settlement1", "settlement2"...
empireG.settlementCount = 0							-- Keep track of settlement count
empireG.entityStats = {}								-- Key is "unit_number" of enties that has extra custom stats
empireG.gui = {}												-- Data for the gui
empireG.runFunctionOnTick = {0, 0, 0}		-- One tickcounter per function
empireG.blockedWorkshops = {}						
empireG.tileCount = 0
empireG.squadTemplates = {}							-- Templates for creating squads
empireG.squadList = {}									-- Squads
empireG.ticksPerSecond = 60							-- The speed at which factorio runs
empireG.timeToGenerateFood = 180				-- Seconds to generate food to max on a world map tile

-- Extended entity stats
empireG.empire_people = {carryWeight = 0.1, moveSpeed = 0.5, huntingSpeed = 0.01, setupSpeed = 0.01}
empireG.empire_backpack = {weight = 0.01, carryWeight = 0.9, moveSpeed = 0.3}
empireG.empire_spear = {weight = 0.01, huntingSpeed = 0.49}
empireG.empire_food = {weight = 0.01}

empireG.listWorkshopConstruction = {"empire_mechanical_belt", "empire_inserter", "empire_backpack", "empire_spear"}
empireG.listSquadSelections = {"empire_people", "empire_backpack", "empire_spear"}
empireG.listFilterSelections = {}
for name,item in pairs(empireG.iMap) do
	table.insert(empireG.listFilterSelections, name)
end


function empireG.log(var, tab)
	tab = tab or ""
	local ret = ""
	if type(var) == "table" then
		for k, v in pairs(var) do
			if type(v) == "table" then
				ret = ret .. tab .. "  [(" .. type(k) .. ")" .. tostring(k) .. "]:\n"
				ret = ret .. empireG.log(v, tab .. "  ")
			else
				ret = ret .. tab .. "  [(" .. type(k) .. ")" .. tostring(k) .. "]: (" .. type(v) .. ")" .. tostring(v) .. "\n"
			end
		end
	else
		ret = ret .. tab .. "  (" .. type(var) .. ")" .. tostring(var) .. "\n"
	end
	return ret
end

function empireG.logF(name, args, level)
	if level == nil then level = 0 end
	if empireG.debug > 2*level then
		log("Function: " .. name)
	end
	if empireG.debug > 2*level+1 then
		for _, arg in pairs(args) do
			log(empireG.log(arg))
		end
	end
end

function empireG.addEvent(tick, f, args)
	empireG.logF("addEvent", {tick, f, args}, 1)
	local lastEvent = nil
	local event = empireG.eventQueue
	while event and event.tick < tick do
		lastEvent = event
		event = event.next
	end
	if lastEvent == nil then
		empireG.eventQueue = {next = event, tick = tick, f = f, args = args}
	else
		lastEvent.next = {next = event, tick = tick, f = f, args = args}
	end
end

function empireG.callEvent(tick)
	if empireG.eventQueue and empireG.eventQueue.tick <= tick then
		empireG.logF("callEvent", {tick}, 1)
		local a = empireG.eventQueue.args
		empireG.eventQueue.f(a[1], a[2], a[3], a[4], a[5], a[6])
		empireG.eventQueue = empireG.eventQueue.next
	end
end