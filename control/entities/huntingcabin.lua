function empire.openHuntingcabinGui(player, entity)
	empireG.logF("openHuntingcabinGui", {player, entity})
	empireG.gui[player.index] = {entity = entity}
	local stats = empireG.surfaces[entity.surface.name]
	local caption = entity.localised_name	
	empire.closeHuntingcabinGui(player)
	local root = player.gui.screen	
	local frame = root.add {type="frame", name="huntingcabinGui", direction="vertical"}
	player.opened = frame
	frame.location = {800,400}
	local title_flow = frame.add{type = "flow", name = "title_flow"}
  local title = title_flow.add{type = "label", caption = caption, style = "frame_title"}
  title.drag_target = frame
  local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "closeHuntingcabinGui"}
	local squadListFlow = frame.add{type = "flow", name = "squadTemplateslow"}
	empire.buildSquadListGui(player.index, squadListFlow, {home = entity.surface.name, task = "none", status = "idle"}, empire.pickHuntingDestinations)
end

function empire.closeHuntingcabinGui(player)
	empireG.logF("closeHuntingcabinGui", {player})
	empire.closeSquadGui(player)
	if player.gui.screen["huntingcabinGui"] ~= nil then player.gui.screen["huntingcabinGui"].destroy() end
	empireG.gui[player.index] = {}
end

function empire.handleHuntingcabinButtonPress(player, element)
	empireG.logF("handleHuntingcabinButtonPress", {player, element})
	if element.name == "closeHuntingcabinGui" then
		empire.closeHuntingcabinGui(player)
	else
		if empire.handleSquadListButtonPress(player, element) then return end
	end
end

function empire.pickHuntingDestinations(player, squad)
	empireG.logF("pickHuntingDestinations", {player, squad})
	empireG.gui[player.index].selectedTiles = {len = 0}
	empireG.gui[player.index].squad = squad
	empireG.gui[player.index].surfaceName = player.surface.name
	player.teleport({x=0, y=0}, "nauvis")
	empire.showFood({0,0})
	player.cursor_stack.set_stack({name = "empire_picker", count = 1})
	empire.openHuntingPathGui(player)
end