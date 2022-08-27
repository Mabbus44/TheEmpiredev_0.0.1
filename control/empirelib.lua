empire = {}
-- Merge required tables into empire table
local empireGui = require("control/empireGui.lua") 
for k,v in pairs(empireGui) do empire[k] = v end
local empireMapGeneration = require("control/empireMapGeneration.lua") 
for k,v in pairs(empireMapGeneration) do empire[k] = v end

function empire.disableCrashsite()
	remote.call("freeplay", "set_disable_crashsite", true)
	remote.call("freeplay", "set_skip_intro", true)
end

function empire.removeCharacter(player)
	if player.character then
		player.character.destroy()
		player.character = nil
	end
end

function empire.createSettlementMap(mapSize)
	local surfaceSettings = table.deepcopy(game.surfaces["nauvis"].map_gen_settings)
	surfaceSettings.width = mapSize
	surfaceSettings.height = mapSize
	empireG.settlementCount = empireG.settlementCount + 1
	log("Creating settlement " .. empireG.settlementCount .. " of size " .. mapSize)
	local newSurface = game.create_surface("settlement" .. empireG.settlementCount, surfaceSettings)	
	newSurface.request_to_generate_chunks({x=0,y=0}, mapSize)
	--Tested that for every 64 map size factorio generates 1 extra chunk in all directions.
	empireG.surfaces[newSurface.name] = {surface = newSurface, chunksGenerated = 0, chunksGoal = ((math.floor(mapSize / 64) + 1) * 2) ^ 2,
		population = 10, maxPopulation = 100, populationDecimals = 0.0, foodPerPerson = 0.01, maxReservePerPerson = 1.2, deadPersonGive = 1, populationGroth = 0,
		foodConsumtion = 0, foodReserves = 12, foodForOnePersonGroth = 2, grothEnabled = true}
	return newSurface
end

function empire.generateChunk(surface, area)
	local minY, maxY, minX, maxX
	if surface.map_gen_settings.height == nil or surface.map_gen_settings.height == 0 then 
		minY = area.left_top.y
		maxY = area.right_bottom.y-1
	else
		minY = math.max(area.left_top.y, math.floor(-surface.map_gen_settings.height/2))
		maxY = math.min(area.right_bottom.y-1, math.floor((surface.map_gen_settings.height-1)/2))
	end
	if surface.map_gen_settings.width == nil or surface.map_gen_settings.width == 0 then 
		minX = area.left_top.x
		maxX = area.right_bottom.x-1
	else
		minX = math.max(area.left_top.x, math.floor(-surface.map_gen_settings.width/2))
		maxX = math.min(area.right_bottom.x-1, math.floor((surface.map_gen_settings.width-1)/2))
	end
	if string.find(surface.name, "settlement") then
		empire.generateSettlementChunk(surface, minY, maxY, minX, maxX)
	elseif surface.name == "nauvis" and empireG.worldMapCreated == true then
		empire.worldMapChunkGenerated(surface, minY, maxY, minX, maxX)
	end
	
	if empireG.surfaces[surface.name] ~= nil then
		empireG.surfaces[surface.name].chunksGenerated = empireG.surfaces[surface.name].chunksGenerated + 1
		if empireG.surfaces[surface.name].chunksGenerated == empireG.surfaces[surface.name].chunksGoal then
			if string.find(surface.name, "settlement") then
				local entity = empire.createEntity(surface, "empire_vault", {x=0, y=0}, nil, "player")
				entity = empire.createEntity(surface, "empire_storage", {x=-3, y=-3}, nil, "player")
				entity.insert({name="empire_mechanical_belt", count=50})
				entity.insert({name="empire_storage", count=10})
				entity.insert({name="empire_inserter", count=20})
				entity.insert({name="empire_mining_drill", count=11})
				entity.insert({name="empire_furnace", count=10})
				entity.insert({name="empire_workshop", count=10})
				entity.insert({name="empire_greenhouse", count=10})
				surface.create_entity{name="iron-ore", position = {x=3, y=3}, force = "neutral"}
				entity = empire.createEntity(surface, "empire_workshop", {x=3, y=-3}, nil, "player")
			end
		end
	end
end

function empire.generateSettlementChunk(surface, minY, maxY, minX, maxX)
	local tiles = {}
	local buildArea = 81
	for y= minY, maxY do
		for x= minX, maxX do
      if x*x+y*y <= buildArea then
				if surface.name == "settlement0" then
					table.insert(tiles, {name = "grass-1", position = {x,y}})
				else
					table.insert(tiles, {name = "sand-1", position = {x,y}})
				end
			else
				table.insert(tiles, {name = "red-desert-0", position = {x,y}})
			end
		end
	end
	surface.set_tiles(tiles)
end

function empire.selectItemGhost(player, itemStack)
	player.cursor_ghost = itemStack
end

function empire.clearInventory(player)
	player.get_main_inventory().clear()
end

function empire.replaceGhosts(surface)
	local entities = surface.find_entities_filtered{name = "entity-ghost"}
	local storages = surface.find_entities_filtered{name = "empire_storage"}	
	for k, entity in pairs(entities) do
		local ghostName = entity.ghost_name
		if empire.takeItemFromStorage(surface, storages, ghostName) then
			local position = entity.position
			local direction = entity.direction
			entity.destroy()
			empire.createEntity(surface, ghostName, position, direction, "player")
		end
	end
end

function empire.createEntity(surface, name, position, direction, force)
	local entity = surface.create_entity{name=name, position = position, direction = direction, force = force}
	local bonusStats = {workerCount = 0, enabled = true, paused = false}
	if name == "empire_vault" then bonusStats = {}
	elseif name == "empire_storage" then 
		bonusStats.workerCount = nil
		bonusStats.filters = {}
	elseif name == "empire_mechanical_belt" then bonusStats.requiredWorkers = 1
	elseif name == "empire_inserter" then 
		bonusStats.requiredWorkers = 2
		empireG.addEvent(game.tick+1, empire.inserterChangeDrop, {{entity}})
	elseif name == "empire_mining_drill" then bonusStats.requiredWorkers = 20
	elseif name == "empire_furnace" then bonusStats.requiredWorkers = 10
	elseif name == "empire_workshop" then 
	  local outputEntity = surface.create_entity{name="empire_workshop_output", position = position, force = force}
		empireG.entityStats[outputEntity.unit_number] = {inputEntity = entity}
		bonusStats.requiredWorkers = 10
		bonusStats.craftingSpeed = 1.0
		bonusStats.recipes = {"empire_mechanical_belt", "empire_inserter"}
		bonusStats.buildingStats = {status = "idle"}
		bonusStats.outputEntity = outputEntity
		local box = entity.bounding_box
		local inserters = surface.find_entities({{box.left_top.x-1.0, box.left_top.y-1.0}, {box.right_bottom.x+1.0, box.right_bottom.y+1.0}})
		empireG.addEvent(game.tick+1, empire.inserterChangeDrop, {inserters})
		local inventory = entity.get_inventory(defines.inventory.chest)
		inventory.insert({name="empire_food", count=100})
	elseif name == "empire_greenhouse" then bonusStats.requiredWorkers = 20
	else log("empire-error: Invalid name in empire.createEntity: " .. name) end
	if bonusStats.requiredWorkers then
		bonusStats.enabled = false
		entity.active = false
	end
	log("Entity " .. entity.name .. " " .. entity.unit_number .. " created (" .. tostring(entity.active) .. ") on surface " .. surface.name)
	empireG.entityStats[entity.unit_number] = bonusStats
	empire.distributeWorkers(surface)
	return entity
end

function empire.distributeWorkers(surface)
	local workers = empireG.surfaces[surface.name].population
	local entities = surface.find_entities()
	local outOfWorkers = false
	for i, entity in pairs(entities) do
		local eStats = empireG.entityStats[entity.unit_number]
		if string.find(entity.name, "empire_") and eStats ~= nil and eStats.workerCount ~= nil then
			if eStats.paused then
				eStats.workerCount = 0
				empire.entitySetEnable(entity, eStats, false)
			elseif outOfWorkers then
				eStats.workerCount = 0
				empire.entitySetEnable(entity, eStats, false)
			else
				eStats.workerCount = math.min(eStats.requiredWorkers, workers)
				workers = workers - eStats.requiredWorkers
				if workers < 0 then
					outOfWorkers = true
					empire.entitySetEnable(entity, eStats, false)
				else
					empire.entitySetEnable(entity, eStats, true)
				end
			end
			--log("Entity " .. entity.unit_number .. " given workers")
		end
	end
end

function empire.entitySetEnable(entity, eStats, val)
	--log("Set enable " .. entity.unit_number .. " from " .. tostring(eStats.enabled) .. " to " .. tostring(val))
	if eStats.enabled == val then return end
	entity.active = val
	eStats.enabled = val
	if eStats.buildingStats then empire.workshopStartBuildItem(entity) end
end

function empire.takeItemFromStorage(surface, storages, itemName)
	for k, storage in pairs(storages) do
		if storage.get_item_count(itemName) > 0 then
			storage.remove_item({name = itemName, count = 1})
			return true
		end
	end
	return false
end

function empire.removeDeconstructed(surface)
	local entities = surface.find_entities_filtered{to_be_deconstructed = true}
	local storages = surface.find_entities_filtered{name = "empire_storage"}	
	for k, entity in pairs(entities) do
		if empire.putItemInStorage(surface, storages, entity) then entity.destroy() end
	end
end

function empire.putItemInStorage(surface, storages, entity)
	if not string.find(entity.name, "empire-") then return end
	for k, storage in pairs(storages) do
		if storage.can_insert(entity.name) then
			storage.insert({name = entity.name, count = 1})
			empireG.entityStats[entity.unit_number].outputEntity.destroy()
			return true
		end
	end
	return false
end

function empire.gatherResources()
	for i=1,empireG.settlementCount do
		local greenhouses = empireG.surfaces["settlement" .. i].surface.find_entities_filtered{name = "empire_greenhouse"}
		for k, entity in pairs(greenhouses) do
			entity.insert({name="empire_food", count=1})
		end
	end
end

function empire.adjustFoodAndPopulation()
	for i=1,empireG.settlementCount do
		local sData = empireG.surfaces["settlement" .. i]
		-- Fill reserves with storage
		local missingReserves = math.floor(sData.population * sData.maxReservePerPerson + sData.foodConsumtion - sData.foodReserves) + 1
		local vaults = empireG.surfaces["settlement" .. i].surface.find_entities_filtered{name = "empire_vault"}
		if vaults[1] ~= nil then
			local vault = vaults[1]
			local fillReserversAmount = vault.get_item_count("empire_food")
			if fillReserversAmount > missingReserves then fillReserversAmount = missingReserves end
			sData.foodReserves = sData.foodReserves + fillReserversAmount
			if fillReserversAmount > 0 then vault.remove_item({name="empire_food", count=fillReserversAmount}) end
		end
		-- Eat from storage
		if sData.population == 0 then sData.populationGroth = 0 else sData.populationGroth = math.max(math.log(sData.population)*0.1, 0.05) end
		sData.foodConsumtion = sData.foodPerPerson * sData.population
		if sData.grothEnabled == true then sData.foodConsumtion = sData.foodConsumtion + sData.populationGroth * sData.foodForOnePersonGroth end
		sData.foodReserves = sData.foodReserves - sData.foodConsumtion
		if sData.foodReserves < 0 then
			-- Starvation
			local deadPeople = math.floor(-sData.foodReserves/sData.deadPersonGive)+1
			sData.population = sData.population - deadPeople
			sData.foodReserves = sData.deadPersonGive * deadPeople
			empire.distributeWorkers(sData.surface)
			sData.grothEnabled = false
		elseif sData.grothEnabled then
			sData.populationDecimals = sData.populationDecimals + sData.populationGroth
			sData.population = sData.population + math.floor(sData.populationDecimals)
			sData.populationDecimals = sData.populationDecimals - math.floor(sData.populationDecimals)
			if sData.population >= sData.maxPopulation then
				sData.population = sData.maxPopulation
				sData.grothEnabled = false
			end
			empire.distributeWorkers(sData.surface)
		end
		if sData.foodReserves < sData.maxReservePerPerson * sData.population * 0.1 then grothEnabled = false end
	end	
end

function empire.restartWorkshops()
	-- it will only start like half of the workshops per run, but whatever, good enough
	for unit_number, entity in pairs(empireG.blockedWorkshops) do
		if empireG.entityStats[unit_number].buildingStats.status == "blocked input" then
			empire.workshopStartBuildItem(entity)
			if empireG.entityStats[unit_number].buildingStats.status ~= "blocked input" then empireG.blockedWorkshops[unit_number] = nil end
		elseif empireG.entityStats[unit_number].buildingStats.status == "blocked output" then
			empire.workshopCompleteItem(entity)
			if empireG.entityStats[unit_number].buildingStats.status ~= "blocked output" then empireG.blockedWorkshops[unit_number] = nil end
		else
			empireG.blockedWorkshops[unit_number] = nil
		end
	end
end

function empire.inserterChangeDrop(inserters)
	for _, inserter in pairs(inserters) do
		if inserter.drop_target and inserter.drop_target.name == "empire_workshop_output" then
			inserter.drop_target = empireG.entityStats[inserter.drop_target.unit_number].inputEntity
		end
	end
end
