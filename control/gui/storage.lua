local empire = {}

function empire.openStorageGui(player, entity)
	local frame = player.gui.relative.add{type="frame", name = "storageFilterGui", direction = "vertical", caption = {"reserve_slots"}}
	frame.anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.bottom, names = {"empire_storage", "empire_greenhouse"}}
	local buttonFlow = frame.add{type = "flow", name = "buttonFlow"}
	local valueFlow = frame.add{type = "flow", name = "valueFlow"}
	local confirmFlow = frame.add{type = "flow", name = "confirmFlow"}
	
	local filters = empireG.entityStats[entity.unit_number].filters
	local firstFilter = nil
	local firstCount = 0
  buttonFlow.add{type = "sprite-button", sprite = "utility/close_white", name = "removeFilter"}
	for name, count in pairs(filters) do
		if firstFilter == nil then
			firstFilter = name
			firstCount = count
		end
		buttonFlow.add{type="sprite-button", sprite="item/" .. iMap[name][2], name=name, number = count}
	end
	buttonFlow.add{type="sprite-button", sprite="empire-add", name="addItem"}
	valueFlow.add{type="slider", name="slider"}
	valueFlow.slider.slider_value = firstCount
	valueFlow.add{type="textfield", numeric=true, name="sliderTextField", text = tostring(firstCount)}
	confirmFlow.add{type="label", caption={"block_remaning"}, name = "blocklbl"}
	confirmFlow.add{type="checkbox", name = "blockCheckbox", state = true}
	confirmFlow.add{type="button", caption={"apply_reservations"}, name="apllyFilters"}
	empireG.gui[player.index] = {entity = entity, selectedFilter = firstFilter}
end

function empire.openStorageItemsGui(player)
	if player.gui.screen["storageItemsGui"] ~= nil then 
		player.gui.screen["storageItemsGui"].bring_to_front()
		return 
	end
	local caption = {"choose_item"}
	local frame = player.gui.screen.add {type="frame", name="storageItemsGui", direction="vertical"}
	frame.location = {800,400}
	local titleFlow = frame.add{type = "flow", name = "titleFlow"}
  local title = titleFlow.add{type = "label", caption = caption, style = "frame_title"}
  title.drag_target = frame
  local pusher = titleFlow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  titleFlow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "closeStorageItemsGui"}

	local entity = empireG.gui[player.index].entity
	local filters = empireG.entityStats[entity.unit_number].filters
	local buttonFlow = frame.add{type = "flow", name = "buttonFlow"}
	for name, item in pairs(iMap) do
		if filters[name] == nil then buttonFlow.add{type="sprite-button", sprite="item/" .. item[2], name=name} end
	end
end

function empire.closeStorageGui(player)
	if player.gui.screen["storageItemsGui"] ~= nil then player.gui.screen["storageItemsGui"].destroy() end
	player.gui.relative["storageFilterGui"].destroy()
	empireG.gui[player.index] = {}
end

function empire.closeStorageItemsGui(player)
	if player.gui.screen["storageItemsGui"] ~= nil then player.gui.screen["storageItemsGui"].destroy() end
end

function empire.updateStorageGui(playerId, frame, val)
	local eStats = empireG.entityStats[empireG.gui[playerId].entity.unit_number]
	local filter = empireG.gui[playerId].selectedFilter
	if filter == nil then return end
	eStats.filters[filter] = val
	frame.buttonFlow[filter].number = val
end

function empire.handleStorageValueChange(event)
	local textfield = event.element.parent["sliderTextField"]
	textfield.text = tostring(event.element.slider_value)
	empire.updateStorageGui(event.player_index, event.element.parent.parent, event.element.slider_value)
end

function empire.handleStorageTextChange(event)
	local fieldVal = tonumber(event.element.text)
	if fieldVal == nil then fieldVal = 0 end
	local slider = event.element.parent["slider"]
	slider.slider_value = fieldVal
	empire.updateStorageGui(event.player_index, event.element.parent.parent, fieldVal)
end

function empire.handleStorageButtonPress(player, element)
	if element.name == "apllyFilters" then 
		empire.applyFilters(player)
		return
	end
	if element.name == "addItem" then
		empire.openStorageItemsGui(player)
		return
	end
	if element.name == "removeFilter" then
		empire.removeStorageGuiFilter(player)
		return
	end
	local eStats = empireG.entityStats[empireG.gui[player.index].entity.unit_number]
	local selectedFilter = eStats.filters[element.name]
	if selectedFilter == nil then return end
	empireG.gui[player.index].selectedFilter = element.name
	local slider = element.parent.parent.valueFlow.slider
	local textField = element.parent.parent.valueFlow.sliderTextField
	slider.slider_value = selectedFilter
	textField.text = tostring(selectedFilter)
end

function empire.handleStorageItemsButtonPress(player, element)
	if element.parent.name ~= "buttonFlow" then return end
	if player.gui.relative.storageFilterGui == nil then return end
	if player.gui.relative.storageFilterGui.buttonFlow[element.name] ~= nil then return end
	empire.addStorageGuiFilter(player, element.name)
end

function empire.addStorageGuiFilter(player, filterName)
	if player.gui.relative.storageFilterGui == nil then return end
	local filterButtonFlow = player.gui.relative.storageFilterGui.buttonFlow
	local buttonFlow = player.gui.screen.storageItemsGui.buttonFlow
	local entity = empireG.gui[player.index].entity
	local filters = empireG.entityStats[entity.unit_number].filters
	filters[filterName] = 1
	filterButtonFlow.addItem.destroy()
	filterButtonFlow.add{type="sprite-button", sprite="item/" .. iMap[filterName][2], name=filterName, number = filters[filterName]}
	filterButtonFlow.add{type="sprite-button", sprite="empire-add", name="addItem"}
	buttonFlow[filterName].destroy()
	player.gui.relative.storageFilterGui.valueFlow.slider.slider_value = filters[filterName]
	player.gui.relative.storageFilterGui.valueFlow.sliderTextField.text = tostring(filters[filterName])
	empireG.gui[player.index].selectedFilter = filterName
end

function empire.removeStorageGuiFilter(player)
	local playerId = player.index
	if player.gui.relative.storageFilterGui == nil then return end
	local filterButtonFlow = player.gui.relative.storageFilterGui.buttonFlow
	local selectedFilter = empireG.gui[playerId].selectedFilter
	if selectedFilter == nil then return end
	local entity = empireG.gui[playerId].entity
	local filters = empireG.entityStats[entity.unit_number].filters
	if filters[selectedFilter] == nil then return end
	filters[selectedFilter] = nil
	filterButtonFlow[selectedFilter].destroy()
	local firstFilter = nil
	local firstCount = 0
	for name, count in pairs(filters) do
		if firstFilter == nil then
			firstFilter = name
			firstCount = count
		end
	end
	player.gui.relative.storageFilterGui.valueFlow.slider.slider_value = firstCount
	player.gui.relative.storageFilterGui.valueFlow.sliderTextField.text = tostring(firstCount)
	empireG.gui[player.index].selectedFilter = firstFilter
	if player.gui.screen["storageItemsGui"] ~= nil then player.gui.screen["storageItemsGui"].destroy() end
end
		
function empire.applyFilters(player)
	local playerId = player.index
	local entity = empireG.gui[playerId].entity	
	local blockRemaning = player.gui.relative.storageFilterGui.confirmFlow.blockCheckbox.state
	local filters = table.deepcopy(empireG.entityStats[entity.unit_number].filters)
	local inventory = entity.get_inventory(defines.inventory.chest)
	local inventorySize = #inventory
	for i = 1, inventorySize do
		inventory.set_filter(i, nil)
	end
	-- First filter itemslots with desired items
	log("\n--------------Filter desired------------")
	for i = 1, inventorySize do
		log(i .. "/" .. inventorySize)
		if inventory[i].valid_for_read then
			local itemName = inventory[i].name
			if filters[itemName] and filters[itemName] > 0 then
				filters[itemName] = filters[itemName] - 1
				inventory.set_filter(i, itemName)
				log("Filtered " .. itemName .. " at " .. i)
			end
		end
	end
	-- Then filter empty slots
	local inventorySlotId = 1
	while inventorySlotId <= inventorySize and (inventory.get_filter(inventorySlotId) ~= nil or inventory[inventorySlotId].valid_for_read) do inventorySlotId = inventorySlotId + 1 end
	log("\n--------------Filter empty------------")
	for filterName, count in pairs(filters) do
		log("name: " .. filterName .. " count: " .. count .. " slot: " .. inventorySlotId)
		for i = 1,count do
			log(i .. "/" .. count .. " slot: " .. inventorySlotId)
			if inventorySlotId <= inventorySize then 
				inventory.set_filter(inventorySlotId, filterName)
				log("Filtered " .. filterName .. " at " .. inventorySlotId)
				filters[filterName] = filters[filterName] - 1
				inventorySlotId = inventorySlotId + 1
				while inventorySlotId <= inventorySize and (inventory.get_filter(inventorySlotId) ~= nil or inventory[inventorySlotId].valid_for_read) do inventorySlotId = inventorySlotId + 1 end
			end
			if inventorySlotId > inventorySize then break end
		end
		if inventorySlotId > inventorySize then break end
	end
	-- Then filter occupied slots
	inventorySlotId = 1
	while inventorySlotId <= inventorySize and inventory.get_filter(inventorySlotId) ~= nil do inventorySlotId = inventorySlotId + 1 end
	log("\n--------------Filter occupied------------")
	for filterName, count in pairs(filters) do
		log("name: " .. filterName .. " count: " .. count)
		for i = 1,count do
			log(i .. "/" .. count)
			if inventorySlotId <= inventorySize then 
				inventory.set_filter(i, filterName)
				log("Filtered " .. filterName .. " at " .. i)
				filters[filterName] = filters[filterName] - 1
				inventorySlotId = inventorySlotId + 1
				while inventorySlotId <= inventorySize and inventory.get_filter(inventorySlotId) ~= nil do inventorySlotId = inventorySlotId + 1 end
			end
			if inventorySlotId > inventorySize then break end
		end
		if inventorySlotId > inventorySize then break end
	end
	-- Then block the rest
	log("\n--------------Block the rest------------")
	if blockRemaning then 
		for i = inventorySlotId, inventorySize do
			log(i .. "/" .. inventorySize)
			if inventory.get_filter(i) == nil then
				inventory.set_filter(i, "empire_blocked")
				log("Blocked " .. i)
			end
		end
	end
end

return empire