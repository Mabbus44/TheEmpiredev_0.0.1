-- Function handeling squads
function empire.createSquad(name, home, template)
	empireG.logF("createSquad", {name, home, template})
  local newSquad = {name = name, template=table.deepcopy(template), squad = table.deepcopy(template),
  	home = home, task = "none", status = "idle", stock = {empire_food = 0}}
  for name, amount in pairs(newSquad.squad) do
    newSquad.squad[name] = 0
  end
  return newSquad
end

function empire.calculateSquadStats(squadStats)
	empireG.logF("calculateSquadStats", {squadStats})
	squadStats.moveSpeed = 0.0						-- Movespeed on worldmap, tiles per second
	squadStats.huntingSpeed = 0.0					-- Huntingspeed, animals per second
	squadStats.setupSpeed = 0.0						-- Time to setup/packup before/after hunting
	squadStats.carryCapacity = 0.0				-- Carrycapacity, stacks
	squadStats.carriedWeight = 0.0				-- Weight of stuff being carried
	
	local squad = squadStats.squad
	local stuffToCarry = table.deepcopy(squad)
	local usedItems = 0
	
	-- empire_people
	if squad == nil or squad.empire_people == nil or squad.empire_people == 0 then return false end
	squadStats.moveSpeed = empireG.empire_people.moveSpeed
	squadStats.huntingSpeed = empireG.empire_people.huntingSpeed * squad.empire_people
	squadStats.setupSpeed = empireG.empire_people.setupSpeed * squad.empire_people + 2
	squadStats.carryCapacity = empireG.empire_people.carryWeight * squad.empire_people

	-- empire_backpack
	if squad.empire_backpack ~= nil and squad.empire_backpack > 0 then
		usedItems = math.min(squad.empire_backpack, squad.empire_people)
		squadStats.carryCapacity = squadStats.carryCapacity + usedItems * empireG.empire_backpack.carryWeight
		stuffToCarry.empire_backpack = stuffToCarry.empire_backpack - usedItems
		squadStats.moveSpeed = math.min(squadStats.moveSpeed, empireG.empire_backpack.moveSpeed)
	end

	-- empire_spear
	if squad.empire_spear ~= nil and squad.empire_spear > 0 then
		usedItems = math.min(squad.empire_spear, squad.empire_people)
		squadStats.huntingSpeed = squadStats.huntingSpeed + empireG.empire_spear.huntingSpeed * usedItems
		stuffToCarry.empire_spear = stuffToCarry.empire_spear - usedItems
	end

	-- calculate carried equipment weight
	for itemName, amount in pairs(stuffToCarry) do
		if empireG[itemName] ~= nil and empireG[itemName].weight ~= nil then
			squadStats.carriedWeight = squadStats.carriedWeight + empireG[itemName].weight * amount
		end
	end
	if squadStats.carriedWeight > squadStats.carryCapacity then return false end
	
	return true
end

function empire.resupplySquad(surface)
	empireG.logF("resupplySquad", {surface})
	local squadQueue = empireG.surfaces[surface.name].squadQueue
	if #squadQueue == 0 then return end
	sStats = empireG.surfaces[surface.name]
	local entitiesWithStorage = surface.find_entities_filtered{name = {"empire_storage", "empire_vault"}}
	local inventories = {}
	for _,entity in pairs(entitiesWithStorage) do
		table.insert(inventories, entity.get_inventory(defines.inventory.chest))
	end
	local squadReady = true
	while #squadQueue > 0 and squadReady do
		local squad = squadQueue[1].squad
		local template = squadQueue[1].template
		squadReady = true
		for key, val in pairs(squad) do
			local missing = template[key] - squad[key]
			if key == "empire_people" then
				local freeWorkers = sStats.freeWorkers
				if freeWorkers > missing then freeWorkers = missing end
				if freeWorkers > 0 then
					missing = missing - freeWorkers
					sStats.freeWorkers = sStats.freeWorkers - freeWorkers
					sStats.population = sStats.population - freeWorkers
					squad[key] = squad[key] + freeWorkers
				end
			else
				for _, inventory in pairs(inventories) do
					if missing > 0 then
						local itemCount = inventory.get_item_count(key)
						if itemCount > missing then itemCount = missing end
						if itemCount > 0 then
							missing = missing - itemCount
							squad[key] = squad[key] + itemCount
							inventory.remove({name=key, count=itemCount})
						end
					end
				end
			end
			if template[key] ~= squad[key] then squadReady = false end
		end
		if squadReady then
			empire.calculateSquadStats(squadQueue[1])
			table.insert(empireG.squadList, squadQueue[1])
			table.remove(squadQueue, 1)
		end
	end
	if #squadQueue > 0 then
		empireG.addEvent(game.tick+180, empire.resupplySquad, {surface})
	end
end