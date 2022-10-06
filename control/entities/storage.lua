function empire.openStorageGui(player, entity)
	empireG.logF("openStorageGui", {player, entity})
	empireG.gui[player.index] = {}
	
	local frame = player.gui.relative.add{type="frame", name = "storageFilterGui", direction = "vertical", caption = {"reserve_slots"}}
	frame.anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.bottom, names = {"empire_storage", "empire_greenhouse"}}
	local buttonAndValueFlow = frame.add{type = "flow", name = "buttonAndValueFlow"}
	local confirmFlow = frame.add{type = "flow", name = "confirmFlow"}
	
	empire.buildItemListBuilderGui(player.index, buttonAndValueFlow, empireG.entityStats[entity.unit_number].itemAmountList, empireG.listFilterSelections)
	confirmFlow.add{type="label", caption={"block_remaning"}, name = "blocklbl"}
	confirmFlow.add{type="checkbox", name = "blockCheckbox", state = true}
	confirmFlow.add{type="button", caption={"apply_reservations"}, name="apllyFilters"}
	empireG.gui[player.index].entity = entity
end

function empire.closeStorageGui(player)
	empireG.logF("closeStorageGui", {player})
	if player.gui.screen["itemGui"] ~= nil then player.gui.screen["itemGui"].destroy() end
	player.gui.relative["storageFilterGui"].destroy()
	empireG.gui[player.index] = {}
end

function empire.handleStorageButtonPress(player, element)
	empireG.logF("handleStorageButtonPress", {player, element})
	if element.name == "apllyFilters" then 
		empire.applyFilters(player)
		return
	end
	empire.handleItemListBuilderButtonPress(player, element)
end
		
function empire.applyFilters(player)
	empireG.logF("applyFilters", {player})
	local playerId = player.index
	local entity = empireG.gui[playerId].entity	
	local blockRemaning = player.gui.relative.storageFilterGui.confirmFlow.blockCheckbox.state
	local filters = table.deepcopy(empireG.entityStats[entity.unit_number].itemAmountList)
	local inventory = entity.get_inventory(defines.inventory.chest)
	local inventorySize = #inventory
	for i = 1, inventorySize do
		inventory.set_filter(i, nil)
	end
	-- First filter itemslots with desired items
	for i = 1, inventorySize do
		if inventory[i].valid_for_read then
			local itemName = inventory[i].name
			if filters[itemName] and filters[itemName] > 0 then
				filters[itemName] = filters[itemName] - 1
				inventory.set_filter(i, itemName)
			end
		end
	end
	-- Then filter empty slots
	local inventorySlotId = 1
	while inventorySlotId <= inventorySize and (inventory.get_filter(inventorySlotId) ~= nil or inventory[inventorySlotId].valid_for_read) do inventorySlotId = inventorySlotId + 1 end
	for filterName, count in pairs(filters) do
		for i = 1,count do
			if inventorySlotId <= inventorySize then 
				inventory.set_filter(inventorySlotId, filterName)
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
	for filterName, count in pairs(filters) do
		for i = 1,count do
			if inventorySlotId <= inventorySize then 
				inventory.set_filter(i, filterName)
				filters[filterName] = filters[filterName] - 1
				inventorySlotId = inventorySlotId + 1
				while inventorySlotId <= inventorySize and inventory.get_filter(inventorySlotId) ~= nil do inventorySlotId = inventorySlotId + 1 end
			end
			if inventorySlotId > inventorySize then break end
		end
		if inventorySlotId > inventorySize then break end
	end
	-- Then block the rest
	if blockRemaning then 
		for i = inventorySlotId, inventorySize do
			if inventory.get_filter(i) == nil then
				inventory.set_filter(i, "empire_blocked")
			end
		end
	end
end
