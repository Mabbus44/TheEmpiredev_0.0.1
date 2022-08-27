local empireG = {}

empireG.worldMapTiles = {}							-- Key is coordinates, so "1,4", "-1,-19"...
empireG.surfaces = {}										-- Key is surface name, so "settlement1", "settlement2"...
empireG.settlementCount = 0							-- Keep track of settlement count
empireG.entityStats = {}								-- Key is "unit_number" of enties that has extra custom stats
empireG.gui = {}												-- Data for the gui
empireG.runFunctionOnTick = {0, 0, 0}		-- One tickcounter per function
empireG.blockedWorkshops = {}						--
empireG.tileCount = 0

function empireG.log(var, tab)
	tab = tab or ""
	local t = type(var)
	local ret = ""
	if type(var) == "table" then
		-- ret = ret .. tab .. "  table:\n"
		for k, v in pairs(var) do
			ret = ret .. tab .. "  key: " .. type(k) .. "-" .. tostring(k) .. "\n"
			ret = ret .. empireG.log(v, tab .. "  ")
		end
	else
		ret = ret .. tab .. "val: " .. type(var) .. "-" .. tostring(var) .. "\n"
	end
	return ret
end

function empireG.addEvent(tick, f, args)
	if game ~= nil then log("addEvent " .. game.tick) end
	local lastEvent = nil
	local event = empireG.eventQueue
	while event and event.tick < tick do
		lastEvent = event
		event = event.next
	end
	if lastEvent == nil then
		empireG.eventQueue = {next = event, tick = tick, f = f, args = args}
		if game ~= nil then log("eventQueue.next= " .. tostring(empireG.eventQueue.next) .. " " .. game.tick) end
	else
		lastEvent.next = {next = event, tick = tick, f = f, args = args}
		if game ~= nil then log("lastEvent.next= " .. tostring(lastEvent.next) .. " " .. game.tick) end
	end
end

function empireG.callEvent(tick)
	if empireG.eventQueue and empireG.eventQueue.tick <= tick then
		if game ~= nil then log("callEvent " .. game.tick) end
		if game ~= nil then log("eventQueue.next " .. tostring(empireG.eventQueue.next) .. " " .. game.tick) end
		local a = empireG.eventQueue.args
		empireG.eventQueue.f(a[1], a[2], a[3], a[4], a[5], a[6])
		empireG.eventQueue = empireG.eventQueue.next
	end
end

return empireG
