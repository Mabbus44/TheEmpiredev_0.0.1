function empire.openWorkshopGui(player, entity)
	empireG.logF("openWorkshopGui", {player, entity})
	local frame = player.gui.relative.add{type="frame", name = "workshopProgressGui", direction = "vertical", caption = {"progress"}}
	frame.anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.top, name = "empire_workshop"}
	local constructionTasksFlow = frame.add{type = "flow", name = "constructionTasksFlow"}
	local progressFlow = frame.add{type = "flow", name = "progressFlow"}
	
	local cTasks = empireG.entityStats[entity.unit_number].constructionTasks
	local taskId = 1
	while cTasks do
		if cTasks.count ~= 1 then 
			constructionTasksFlow.add{type="sprite-button", sprite="item/" .. empireG.iMap[cTasks.name][2], name=tostring(taskId), number = cTasks.count}
		else
			constructionTasksFlow.add{type="sprite-button", sprite="item/" .. empireG.iMap[cTasks.name][2], name=tostring(taskId)}
		end
		taskId = taskId + 1
		cTasks = cTasks.next
	end
	constructionTasksFlow.add{type="sprite-button", sprite="empire-add", name="construct"}
	progressFlow.add{type="progressbar", name="progressbar"}
	local eStats = empireG.entityStats[entity.unit_number]
	empireG.gui[player.index] = {entity = entity, buildingStatus = eStats.buildingStats}
end

function empire.closeWorkshopGui(player)
	empireG.logF("closeWorkshopGui", {player})
	if player.gui.screen["itemGui"] ~= nil then player.gui.screen["itemGui"].destroy() end
	player.gui.relative["workshopProgressGui"].destroy()
	empireG.gui[player.index] = {}
end

function empire.handleWorkshopButtonPress(player, element)
	empireG.logF("handleWorkshopButtonPress", {player, element})
	local eStats = empireG.entityStats[empireG.gui[player.index].entity.unit_number]
	if element.name == "construct" then
		empire.openItemGui(empire.workshopAddToQueue, player, eStats.recipes, true, true)
		return
	end
	if element.parent == nil or element.parent.name ~= "constructionTasksFlow" then return end
	local cTasksFlow = element.parent
	local cTasks = eStats.constructionTasks
	local taskId = tonumber(element.name)
	local findTaskId = 1
	local lastTask = nil
	if taskId == nil or taskId < 1 then return end
	while cTasks and findTaskId ~= taskId do
		findTaskId = findTaskId + 1
		lastTask = cTasks
		cTasks = cTasks.next
	end
	if cTasks == nil then return end
	
	if lastTask then lastTask.next = cTasks.next end
	if taskId == 1 then
		eStats.constructionTasks.count = 1
		player.gui.relative.workshopProgressGui.constructionTasksFlow["1"].number = nil
	else
		element.destroy()
		taskId = taskId + 1
		while cTasksFlow[tostring(taskId)] do
			cTasksFlow[tostring(taskId)].name = tostring(taskId-1)
			taskId = taskId + 1
		end
		local progressbar = cTasksFlow.parent.progressFlow.progressbar
		progressbar.value = 0.0
	end
end

function empire.workshopAddToQueue(player, itemName, itemCount)
	empireG.logF("workshopAddToQueue", {player, itemName, itemCount})
	local entity = empireG.gui[player.index].entity
	local eStats = empireG.entityStats[entity.unit_number]
	local cTasks = eStats.constructionTasks
	local newTask = {name = itemName, count = itemCount}
	local taskId = 1
	if cTasks == nil then
		eStats.constructionTasks = newTask
	else
		taskId = 2
		while cTasks.next do
			taskId = taskId + 1
			cTasks = cTasks.next
		end
		cTasks.next = newTask
	end
	local cTasksFlow = player.gui.relative.workshopProgressGui.constructionTasksFlow
	cTasksFlow.construct.destroy()
	if newTask.count == 1 then 
		cTasksFlow.add{type="sprite-button", sprite="item/" .. empireG.iMap[newTask.name][2], name=tostring(taskId)}
	else
		cTasksFlow.add{type="sprite-button", sprite="item/" .. empireG.iMap[newTask.name][2], name=tostring(taskId), number = newTask.count}
	end
	cTasksFlow.add{type="sprite-button", sprite="empire-add", name="construct"}
	if taskId == 1 then empire.workshopStartBuildItem(entity) end
end

function empire.workshopStartBuildItem(entity)
	empireG.logF("workshopStartBuildItem", {entity})
	local eStats = empireG.entityStats[entity.unit_number]
	local cTasks = eStats.constructionTasks
	if cTasks == nil then
		-- nothing to build
		eStats.buildingStats.status = "idle"
		return
	end
	-- if disabled and building, then pause
	if not eStats.enabled then
		if eStats.buildingStats.status == "blocked input" then eStats.buildingStats.status = "idle" end
		if eStats.buildingStats.status == "building" then empire.workshopPauseBuildItem(entity) end
		return
	end
	-- already building
	if eStats.buildingStats.status == "building" then return end 
	if eStats.buildingStats.status ~= "paused" then
		local inventory = entity.get_inventory(defines.inventory.chest)
		local recipe = game.recipe_prototypes[cTasks.name]
		local ingredients = recipe.ingredients
		local hasIngredients = true
		for i, ingredient in pairs(ingredients) do
			if inventory.get_item_count(ingredient.name) < ingredient.amount then hasIngredients = false end
		end
		if hasIngredients then
			-- build
			for i, ingredient in pairs(ingredients) do
				inventory.remove({name = ingredient.name, count = ingredient.amount})
			end
			eStats.buildingStats.status = "building"
			eStats.buildingStats.startTick = game.tick
			eStats.buildingStats.buildTime = math.floor(recipe.energy/eStats.craftingSpeed*60)
			empireG.addEvent(eStats.buildingStats.startTick + eStats.buildingStats.buildTime, empire.workshopCompleteItem, {entity})
		else
			-- try again later
			eStats.buildingStats.status = "blocked input"
			empireG.blockedWorkshops[entity.unit_number] = entity
		end
		return
	end
	-- status=="paused"
	-- resume production
	eStats.buildingStats.status = "building"
	eStats.buildingStats.startTick = game.tick - eStats.buildingStats.ticksBuilt
	empireG.addEvent(eStats.buildingStats.startTick + eStats.buildingStats.buildTime, empire.workshopCompleteItem, {entity})
end

function empire.workshopPauseBuildItem(entity)
	empireG.logF("workshopPauseBuildItem", {entity})
	local eStats = empireG.entityStats[entity.unit_number]
	if eStats.buildingStats.status ~= "building" then return end
	eStats.buildingStats.status = "paused"
	eStats.buildingStats.ticksBuilt = game.tick - eStats.buildingStats.startTick
	-- remove build task from event queue
	local event = empireG.eventQueue
	local lastEvent = nil
	while event do
		if event.tick == eStats.buildingStats.startTick + eStats.buildingStats.buildTime and event.f == empire.workshopCompleteItem and event.args[1] == entity then
			if lastEvent == nil then
				empireG.eventQueue = empireG.eventQueue.next
			else
				lastEvent.next = event.next
			end
			return
		end
		lastEvent = event
		event = event.next
	end
end

function empire.workshopCompleteItem(entity)
	empireG.logF("workshopCompleteItem", {entity})
	local eStats = empireG.entityStats[entity.unit_number]
	local task = eStats.constructionTasks
	if task == nil then return end
	local inventory = eStats.outputEntity.get_inventory(defines.inventory.chest)
	if inventory.get_item_count() >= 5 then
		-- try again later
		eStats.buildingStats.status = "blocked output"
		empireG.blockedWorkshops[entity.unit_number] = entity
		return
	end
	-- add products to output
	local recipe = game.recipe_prototypes[task.name]
	local products = recipe.products
	for _, product in pairs(products) do
		inventory.insert({name = product.name, count = product.amount})
	end
	-- remove button
	if task.count == 1 then
		eStats.constructionTasks = task.next
		for k, player in pairs(game.players) do
			if empireG.gui[player.index].entity and empireG.gui[player.index].entity.unit_number == entity.unit_number then
				local cTasksFlow = player.gui.relative.workshopProgressGui.constructionTasksFlow
				cTasksFlow["1"].destroy()
				local taskId = 2
				while cTasksFlow[tostring(taskId)] do
					cTasksFlow[tostring(taskId)].name = tostring(taskId-1)
					taskId = taskId + 1
				end
			end
		end
	end
	-- decrese number on button
	if task.count > 1 then
		task.count = task.count - 1
		for k, player in pairs(game.players) do
			if empireG.gui[player.index].entity and empireG.gui[player.index].entity.unit_number == entity.unit_number then
				player.gui.relative.workshopProgressGui.constructionTasksFlow["1"].number = task.count
			end
		end
	end
	eStats.buildingStats.status = "idle"
	if eStats.constructionTasks then empire.workshopStartBuildItem(entity) end
end