function empire.openItemGui(func, player, itemList, valueButtons, infiniteButton)
	empireG.logF("openItemGui", {func, player, itemList, valueButtons, infiniteButton})
	empireG.gui[player.index].itemGuiFunction = func
	if player.gui.screen["itemGui"] ~= nil then 
		player.gui.screen["itemGui"].destroy()
	end
	local caption = {"choose_item"}
	local frame = player.gui.screen.add {type="frame", name="itemGui", direction="vertical"}
	frame.location = {800,400}
	local titleFlow = frame.add{type = "flow", name = "titleFlow"}
  local title = titleFlow.add{type = "label", caption = caption, style = "frame_title"}
  title.drag_target = frame
  local pusher = titleFlow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  titleFlow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "closeItemGui"}

	local buttonFlow = frame.add{type = "flow", name = "buttonFlow"}
	for i, name in pairs(itemList) do
		buttonFlow.add{type="sprite-button", sprite="item/" .. empireG.iMap[name][2], name=name}
	end
	if valueButtons then
		local valueFlow = frame.add{type = "flow", name = "valueFlow"}
		valueFlow.add{type="label", caption={"amount"}, name = "lbl1"}
		valueFlow.add{type="textfield", numeric=true, name="valueText", text = "1"}
		if infiniteButton then
			valueFlow.add{type="label", caption={"infinite"}, name = "lbl2"}
			valueFlow.add{type="checkbox", name = "infinite", state = false}
		end
	end
end

function empire.handleItemGuiButtons(player, element)
	empireG.logF("handleItemGuiButtons", {player, element})
	if element.name == "closeItemGui" then
		player.gui.screen["itemGui"].destroy()
		return
	end
	if element.parent.name ~= "buttonFlow" then return end

	local valueFlow = element.parent.parent.valueFlow
	if valueFlow == nil then
		empireG.gui[player.index].itemGuiFunction(player, element.name)
		return
	end
	local value = tonumber(valueFlow.valueText.text)
	if value == nil then value = 1 end
	if valueFlow.infinite ~= nil and valueFlow.infinite.state then value = 0 end
	empireG.gui[player.index].itemGuiFunction(player, element.name, value)
end