function empire.buildItemListBuilderGui(playerId, baseFrame, selectedList, allowedList)
	empireG.logF("buildItemListBuilderGui", {playerId, baseFrame, list})
	local buttonFlow = baseFrame.add{type = "flow", name = "ILBButtonFlow"}
	local valueFlow = baseFrame.add{type = "flow", name = "ILBValueFlow"}
	empireG.gui[playerId].selectedList = selectedList
	empireG.gui[playerId].allowedList = allowedList
	empireG.gui[playerId].itemListBuilderBaseFrame = baseFrame
	
	local firstItem = nil
	local firstCount = 0
  buttonFlow.add{type = "sprite-button", sprite = "utility/close_white", name = "removeItem"}
	for name, count in pairs(selectedList) do
		if firstItem == nil then
			firstItem = name
			firstCount = count
		end
		buttonFlow.add{type="sprite-button", sprite="item/" .. empireG.iMap[name][2], name=name, number = count}
	end
	buttonFlow.add{type="sprite-button", sprite="empire-add", name="addItem"}
	valueFlow.add{type="slider", name="slider"}
	valueFlow.slider.slider_value = firstCount
	valueFlow.add{type="textfield", numeric=true, name="sliderTextField", text = tostring(firstCount)}
	empireG.gui[playerId].selectedItem = firstItem
end

function empire.updateItemListBuilderGui(playerId, frame, val)
	empireG.logF("updateItemListBuilderGui", {playerId, frame, val})
	local selectedItem = empireG.gui[playerId].selectedItem
	if selectedItem == nil then return end
	empireG.gui[playerId].selectedList[selectedItem] = val
	frame.ILBButtonFlow[selectedItem].number = val
end

function empire.handleItemListBuilderValueChange(event)
	empireG.logF("handleItemListBuilderValueChange", {event})
	local textfield = event.element.parent["sliderTextField"]
	textfield.text = tostring(event.element.slider_value)
	empire.updateItemListBuilderGui(event.player_index, event.element.parent.parent, event.element.slider_value)
end

function empire.handleItemListBuilderTextChange(event)
	empireG.logF("handleItemListBuilderTextChange", {event})
	local fieldVal = tonumber(event.element.text)
	if fieldVal == nil then fieldVal = 0 end
	local slider = event.element.parent["slider"]
	slider.slider_value = fieldVal
	empire.updateItemListBuilderGui(event.player_index, event.element.parent.parent, fieldVal)
end

function empire.handleItemListBuilderButtonPress(player, element)
	empireG.logF("handleItemListBuilderButtonPress", {player, element})
	if element.name == "addItem" then
		local gui = empireG.gui[player.index]
		gui.remainingList = {}
		for _, itemName in pairs(gui.allowedList) do
			if gui.selectedList[itemName] == nil then
				table.insert(gui.remainingList, itemName)
			end
		end
		empire.openItemGui(empire.addItemListBuilderItem, player, gui.remainingList, true, false)
		return
	end
	if element.name == "removeItem" then
		empire.removeItemListBuilderItem(player)
		return
	end
	if element.parent.name ~= "ILBButtonFlow" then return end
	local selectedItem = empireG.gui[player.index].selectedList[element.name]
	if selectedItem == nil then return end
	empireG.gui[player.index].selectedItem = element.name
	local slider = element.parent.parent.ILBValueFlow.slider
	local textField = element.parent.parent.ILBValueFlow.sliderTextField
	slider.slider_value = selectedItem
	textField.text = tostring(selectedItem)
end

function empire.addItemListBuilderItem(player, itemName, value)
	empireG.logF("addItemListBuilderItem", {player, itemName, value})
	local itemButtonFlow = 	empireG.gui[player.index].itemListBuilderBaseFrame.ILBButtonFlow
	local valueFlow = itemButtonFlow.parent.ILBValueFlow
	local buttonFlow = player.gui.screen.itemGui.buttonFlow
	local entity = empireG.gui[player.index].entity
	empireG.gui[player.index].selectedList[itemName] = value
	itemButtonFlow.addItem.destroy()
	itemButtonFlow.add{type="sprite-button", sprite="item/" .. empireG.iMap[itemName][2], name=itemName, number = value}
	itemButtonFlow.add{type="sprite-button", sprite="empire-add", name="addItem"}
	buttonFlow[itemName].destroy()
	valueFlow.slider.slider_value = value
	valueFlow.sliderTextField.text = tostring(value)
	empireG.gui[player.index].selectedItem = itemName
end

function empire.removeItemListBuilderItem(player)
	empireG.logF("removeItemListBuilderItem", {player})
	local playerId = player.index
	local itemButtonFlow = empireG.gui[playerId].itemListBuilderBaseFrame.ILBButtonFlow
	local valueFlow = itemButtonFlow.parent.ILBValueFlow
	local selectedItem = empireG.gui[playerId].selectedItem
	if selectedItem == nil then return end
	local entity = empireG.gui[playerId].entity
	local selectedList = empireG.gui[playerId].selectedList
	
	if selectedList[selectedItem] == nil then return end
	selectedList[selectedItem] = nil
	itemButtonFlow[selectedItem].destroy()
	local firstFilter = nil
	local firstCount = 0
	for name, count in pairs(selectedList) do
		if firstFilter == nil then
			firstFilter = name
			firstCount = count
		end
	end
	valueFlow.slider.slider_value = firstCount
	valueFlow.sliderTextField.text = tostring(firstCount)
	empireG.gui[player.index].selectedItem = firstFilter
	if player.gui.screen["itemGui"] ~= nil then player.gui.screen["itemGui"].destroy() end
end