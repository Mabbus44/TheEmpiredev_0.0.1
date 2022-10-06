-- Window. Create a squad or template
function empire.openformSquadGui(player)
	empireG.logF("openformSquadGui", {player})
	if player.gui.screen["formSquad"] ~= nil then 
		empire.closeFormSquadGui(player)
	end
	local caption = {"form_a_squad"}
	local frame = player.gui.screen.add {type="frame", name="formSquad", direction="vertical"}
	frame.location = {800,400}
	local titleFlow = frame.add{type = "flow", name = "titleFlow"}
  local title = titleFlow.add{type = "label", caption = caption, style = "frame_title"}
  title.drag_target = frame
  local pusher = titleFlow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  titleFlow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "closeFormSquadGui"}

	if empireG.gui[player.index].formingSquad == nil then
		empireG.gui[player.index].formingSquad = {}
	end
	empireG.gui[player.index].itemList = empireG.listSquadSelections
	frame.add{type="label", caption={"name"}, name = "lbl1"}
	frame.add{type="textfield", numeric=false, name="squadNameTF", text = ""}	
	local itemListBuilderFlow = frame.add{type = "flow", name = "itemListBuilderFlow"}
	empire.buildItemListBuilderGui(player.index, itemListBuilderFlow, empireG.gui[player.index].formingSquad, empireG.listSquadSelections)	
	local buttonFlow = frame.add{type = "flow", name = "buttonFlow"}
	buttonFlow.add{type="button", caption={"create_this_squad"}, name = "createThisSquadBtn"}
	buttonFlow.add{type="button", caption={"save_as_template"}, name = "saveSquadAsTemplateBtn"}
end

function empire.closeFormSquadGui(player)
	empireG.logF("closeFormSquadGui", {player})
	if player.gui.screen["itemGui"] ~= nil then player.gui.screen["itemGui"].destroy() end
	if player.gui.screen["formSquad"] ~= nil then player.gui.screen["formSquad"].destroy() end
end

function empire.handleFormSquadGuiButtons(player, element)
	empireG.logF("handleFormSquadGuiButtons", {player, element})
	local sStats = empireG.surfaces[empireG.gui[player.index].entity.surface.name]
	if element.name == "closeFormSquadGui" then
		empire.closeFormSquadGui(player)
	elseif element.name == "createThisSquadBtn" then
		if element.parent.parent.squadNameTF.text == nil or element.parent.parent.squadNameTF.text == "" then return end
		local newSquad = empire.createSquad(element.parent.parent.squadNameTF.text, empireG.gui[player.index].entity.surface.name, empireG.gui[player.index].formingSquad)
		if empire.calculateSquadStats({squad = empireG.gui[player.index].formingSquad}) then
			table.insert(sStats.squadQueue, newSquad)
			if #(sStats.squadQueue) == 1 then empire.resupplySquad(empireG.gui[player.index].entity.surface) end
		end
	elseif element.name == "saveSquadAsTemplateBtn" then
		if element.parent.parent.squadNameTF.text == nil or element.parent.parent.squadNameTF.text == "" then return end
		local newTemplate = {name = element.parent.parent.squadNameTF.text, template = table.deepcopy(empireG.gui[player.index].formingSquad)}
		if empire.calculateSquadStats({squad = empireG.gui[player.index].formingSquad}) then
			table.insert(empireG.squadTemplates, newTemplate)
		end
	else
		empire.handleItemListBuilderButtonPress(player, element)
	end
end