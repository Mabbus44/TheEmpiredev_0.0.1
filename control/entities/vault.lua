function empire.openVaultGui(player, entity)
	empireG.logF("openVaultGui", {player, entity})
	empire.closeVaultGui(player)
	empireG.gui[player.index] = {entity = entity}
	local stats = empireG.surfaces[entity.surface.name]
	local text = "Population " .. stats.population .. "/" .. stats.maxPopulation
	local caption = entity.localised_name	
	local root = player.gui.screen	
	local frame = root.add {type="frame", name="vaultGui", direction="vertical"}
	player.opened = frame
	frame.location = {800,400}
	local title_flow = frame.add{type = "flow", name = "title_flow"}
  local title = title_flow.add{type = "label", caption = caption, style = "frame_title"}
  title.drag_target = frame
  local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "closeVaultGui"}
	local label = frame.add{type="label", caption=text}
	label.drag_target = frame
	frame.add{type="button", caption={"form_a_squad"}, name = "formSquadBtn"}
	local squadQueueFlow = frame.add{type = "flow", name = "squadQueueFlow"}
	local squadListFlow = frame.add{type = "flow", name = "squadListFlow"}
	local squadTemplateslow = frame.add{type = "flow", name = "squadTemplateslow"}
	empire.buildSquadQueueGui(player.index, squadQueueFlow)
	empire.buildSquadListGui(player.index, squadListFlow, {home = entity.surface.name})
	empire.buildSquadTemplatesGui(player.index, squadTemplateslow)
end

function empire.closeVaultGui(player)
	empireG.logF("closeVaultGui", {player})
	empire.closeFormSquadGui(player)
	empire.closeSquadGui(player)
	if player.gui.screen["vaultGui"] ~= nil then player.gui.screen["vaultGui"].destroy() end
	empireG.gui[player.index] = {}
end

function empire.handleVaultButtonPress(player, element)
	empireG.logF("handleVaultButtonPress", {player, element})
	if element.name == "formSquadBtn" then 
		empire.openformSquadGui(player)
	elseif element.name == "closeVaultGui" then
		empire.closeVaultGui(player)
	else
		if empire.handleSquadQueueButtonPress(player, element) then return end
		if empire.handleSquadListButtonPress(player, element) then return end
		if empire.handleSquadTemplatesButtonPress(player, element) then return end
	end
end
