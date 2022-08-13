local empire = {}
-- Merge required tables into empire table
local empiregui = require("control/empiregui.lua") 
for k,v in pairs(empiregui) do empire[k] = v end

function empire.disableCrashsite()
	remote.call("freeplay", "set_disable_crashsite", true)
	remote.call("freeplay", "set_skip_intro", true)
end

function empire.removeCharacter(player)
	player.character.destroy()
	player.character = nil
end

function empire.createWorldMap()
	local mapSize = 10
	local surfaceSettings = table.deepcopy(game.surfaces["nauvis"].map_gen_settings)
	surfaceSettings.width = mapSize
	surfaceSettings.height = mapSize
	local worldMap = game.create_surface("worldMap", surfaceSettings)
	--Tested that for every 64 map size factorio generates 1 extra chunk in all directions.
	empireG.surfaces[worldMap.name] = {chunksGenerated = 0, chunksGoal = ((math.floor(mapSize / 64) + 1) * 2) ^ 2}
	worldMap.request_to_generate_chunks({x=0,y=0}, mapSize)
	for k, player in pairs(game.players) do
		player.teleport({x=0, y=0}, worldMap)
	end
end

function empire.createSettlementMap(mapSize)
	local surfaceSettings = table.deepcopy(game.surfaces["nauvis"].map_gen_settings)
	surfaceSettings.width = mapSize
	surfaceSettings.height = mapSize
	empireG.settlementCount = empireG.settlementCount + 1
	local newSurface = game.create_surface("settlement" .. empireG.settlementCount, surfaceSettings)	
	newSurface.request_to_generate_chunks({x=0,y=0}, mapSize)
	--Tested that for every 64 map size factorio generates 1 extra chunk in all directions.
	empireG.surfaces[newSurface.name] = {surface = newSurface, chunksGenerated = 0, chunksGoal = ((math.floor(mapSize / 64) + 1) * 2) ^ 2,
		population = 10, maxPopulation = 100, populationDecimals = 0.0, foodPerPerson = 0.01, maxReservePerPerson = 1.2, deadPersonGive = 1, populationGroth = 0,
		foodConsumtion = 0, foodReserves = 12, foodForOnePersonGroth = 2, grothEnabled = true}
	return newSurface
end

function empire.generateChunk(surface, area)
	local minY = math.max(area.left_top.y, math.floor(-surface.map_gen_settings.height/2))
	local maxY = math.min(area.right_bottom.y-1, math.floor((surface.map_gen_settings.height-1)/2))
	local minX = math.max(area.left_top.x, math.floor(-surface.map_gen_settings.width/2))
	local maxX = math.min(area.right_bottom.x-1, math.floor((surface.map_gen_settings.width-1)/2))
	if string.find(surface.name, "settlement") then
		empire.generateSettlementChunk(surface, minY, maxY, minX, maxX)
	elseif string.find(surface.name, "world") then
		empire.generateWorldMapChunk(surface, minY, maxY, minX, maxX)
	end
	
	if empireG.surfaces[surface.name] ~= nil then
		empireG.surfaces[surface.name].chunksGenerated = empireG.surfaces[surface.name].chunksGenerated + 1
		if empireG.surfaces[surface.name].chunksGenerated == empireG.surfaces[surface.name].chunksGoal then
			if string.find(surface.name, "settlement") then
				local entity = empire.createEntity(surface, "empire-vault", {x=0, y=0}, nil, "player")
				entity = empire.createEntity(surface, "empire-storage", {x=-3, y=-3}, nil, "player")
				entity.insert({name="empire-mechanical-belt", count=10})
				entity.insert({name="empire-storage", count=2})
				entity.insert({name="empire-inserter", count=3})
				entity.insert({name="empire-mining-drill", count=3})
				entity.insert({name="empire-furnace", count=3})
				entity.insert({name="empire-workshop", count=3})
				entity.insert({name="empire-greenhouse", count=3})
				surface.create_entity{name="iron-ore", position = {x=3, y=3}, force = "neutral"}
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

function empire.generateWorldMapChunk(surface, minY, maxY, minX, maxX)
	local tiles = {}
	local setTiles = {}
	for x = -10,9 do
		setTiles[x] = {}
	end
	setTiles[0][0] = {name = "grass-1", position = {0, 0}}
	setTiles[2][2] = {name = "grass-1", position = {2, 2}}
	for y= minY, maxY do
		for x= minX, maxX do
			if x==0 and y == 0 then
				local newSurface = empire.createSettlementMap(100)
				local tile = surface.create_entity{name="empire-world-map-tile", position = {x=0, y=0}, force = "neutral"}
				empireG.worldMapTiles["" .. tile.position.x .. "," .. tile.position.y] = {surface = newSurface}
			end
			if x==2 and y == 2 then
				--local newSurface = empire.createSettlementMap(70)
				--local tile = surface.create_entity{name="empire-world-map-tile", position = {x=2, y=2}, force = "neutral"}
				--empireG.worldMapTiles["" .. tile.position.x .. "," .. tile.position.y] = {surface = newSurface}
			end
			if setTiles[x] ~= nil and setTiles[x][y] ~= nil then
				table.insert(tiles, setTiles[x][y])
			else
				table.insert(tiles, {name = "sand-1", position = {x, y}})
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
	local storages = surface.find_entities_filtered{name = "empire-storage"}	
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
	local bonusStats = {workerCount = 0, paused = false, enabled = false}
	if name == "empire-vault" then bonusStats = {}
	elseif name == "empire-storage" then 
		bonusStats.workerCount = nil
		bonusStats.filters = {general = 16, empire-mechanical-belt = 10, empire-storage = 11}
	elseif name == "empire-mechanical-belt" then bonusStats.requiredWorkers = 1
	elseif name == "empire-inserter" then bonusStats.requiredWorkers = 2
	elseif name == "empire-mining-drill" then bonusStats.requiredWorkers = 20
	elseif name == "empire-furnace" then bonusStats.requiredWorkers = 10
	elseif name == "empire-workshop" then bonusStats.requiredWorkers = 10
	elseif name == "empire-greenhouse" then bonusStats.requiredWorkers = 20
	else log("empire-error: Invalid name in empire.createEntity: " .. name) end
	empireG.entityStats[entity.unit_number] = bonusStats
	empire.distrubuteWorkers(surface)
	return entity
end

function empire.distrubuteWorkers(surface)
	local workers = empireG.surfaces[surface.name].population
	local entities = surface.find_entities()
	local outOfWorkers = false
	for i, entity in pairs(entities) do
		if string.find(entity.name, "empire-") and empireG.entityStats[entity.unit_number] ~= nil and empireG.entityStats[entity.unit_number].workerCount ~= nil then
			local eStats = empireG.entityStats[entity.unit_number]
			if eStats.paused then
				eStats.workerCount = 0
				eStats.enabled = false
			elseif outOfWorkers then
				eStats.workerCount = 0
				eStats.enabled = false
			else
				eStats.workerCount = math.min(eStats.requiredWorkers, workers)
				workers = workers - eStats.requiredWorkers
				if workers < 0 then
					outOfWorkers = true
					eStats.enabled = false
				else
					eStats.enabled = true
				end
			end
		end
	end
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
	local storages = surface.find_entities_filtered{name = "empire-storage"}	
	for k, entity in pairs(entities) do
		if empire.putItemInStorage(surface, storages, entity.name) then entity.destroy() end
	end
end

function empire.putItemInStorage(surface, storages, itemName)
	for k, storage in pairs(storages) do
		if storage.can_insert(itemName) then
			storage.insert({name = itemName, count = 1})
			return true
		end
	end
	return false
end

function empire.gatherResources()
	for i=1,empireG.settlementCount do
		local greenhouses = empireG.surfaces["settlement" .. i].surface.find_entities_filtered{name = "empire-greenhouse"}
		for k, entity in pairs(greenhouses) do
			entity.insert({name="empire-food", count=1})
		end
	end
end

function empire.adjustFoodAndPopulation()
	for i=1,empireG.settlementCount do
		local sData = empireG.surfaces["settlement" .. i]
		-- Fill reserves with storage
		local missingReserves = math.floor(sData.population * sData.maxReservePerPerson + sData.foodConsumtion - sData.foodReserves) + 1
		local vaults = empireG.surfaces["settlement" .. i].surface.find_entities_filtered{name = "empire-vault"}
		if vaults[1] ~= nil then
			local vault = vaults[1]
			local fillReserversAmount = vault.get_item_count("empire-food")
			if fillReserversAmount > missingReserves then fillReserversAmount = missingReserves end
			sData.foodReserves = sData.foodReserves + fillReserversAmount
			if fillReserversAmount > 0 then vault.remove_item({name="empire-food", count=fillReserversAmount}) end
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
			empire.distrubuteWorkers(sData.surface)
			sData.grothEnabled = false
		elseif sData.grothEnabled then
			sData.populationDecimals = sData.populationDecimals + sData.populationGroth
			sData.population = sData.population + math.floor(sData.populationDecimals)
			sData.populationDecimals = sData.populationDecimals - math.floor(sData.populationDecimals)
			if sData.population >= sData.maxPopulation then
				sData.population = sData.maxPopulation
				sData.grothEnabled = false
			end
			empire.distrubuteWorkers(sData.surface)
		end
		if sData.foodReserves < sData.maxReservePerPerson * sData.population * 0.1 then grothEnabled = false end
	end	
end

return empire