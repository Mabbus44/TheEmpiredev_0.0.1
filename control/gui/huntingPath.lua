-- Window and map functionality for choosing a hunting path
function empire.openHuntingPathGui(player)
	empireG.logF("openHuntingPathGui", {player})
	local root = player.gui.screen	
	local frame = root.add {type="frame", name="huntingPathGui", direction="vertical"}
  local guiBackup = empireG.gui[player.index]
  player.opened = frame     -- This triggers an event to close current gui, which clears epireG.gui[player.index]
  empireG.gui[player.index] = guiBackup
	frame.location = {400,50}
	local title_flow = frame.add{type = "flow", name = "title_flow"}
  local title = title_flow.add{type = "label", caption = {"select_tiles"}, style = "frame_title"}
  title.drag_target = frame
  local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "closeHuntingPathGui"}
	local contentFlow = frame.add{type = "flow", name = "contentFlow"}
  contentFlow.add{type="button", caption={"finish_hunting_path"}, name = "finishHuntingPath"}
end

function empire.closeHuntingPathGui(player)
	empireG.logF("closeHuntingPathGui", {player})
	if player.gui.screen["huntingPathGui"] ~= nil then player.gui.screen["huntingPathGui"].destroy() end
	empireG.gui[player.index] = {}
end

function empire.handleHuntingPathButtonPress(player, element)
	empireG.logF("handleHuntingPathButtonPress", {player, element})
	if element.name == "closeHuntingPathGui" then
    local gui = empireG.gui[player.index]
		empire.closeHuntingPathGui(player)
    player.cursor_stack.set_stack(nil)
		empire.clearText()
    player.teleport({x=0, y=0}, gui.surfaceName)
  elseif element.name == "finishHuntingPath" then
    local gui = empireG.gui[player.index]
    local sData = empireG.surfaces[gui.surfaceName]
    if gui.selectedTiles.len > 0 then
      gui.squad.task = "hunting"
      gui.squad.status = "moving"
      gui.squad.position = sData.position
			local p = {x=math.floor(sData.position.x), y=math.floor(sData.position.y)}
			local selectedTileInfo = {pStr = tostring(p.x) .. "," .. tostring(p.y), p={x=p.x, y=p.y},index=gui.selectedTiles.len+1}
			gui.selectedTiles[selectedTileInfo.pStr] = selectedTileInfo
			gui.selectedTiles[selectedTileInfo.index] = selectedTileInfo
			gui.selectedTiles.len = gui.selectedTiles.len + 1
			gui.squad.huntingPathTiles = gui.selectedTiles
      gui.squad.huntingPathGoal = 1
      table.insert(sData.huntingPaths, {squad = gui.squad, tiles = gui.selectedTiles})
      empire.huntStartMoving(gui.squad)
    end
		empire.closeHuntingPathGui(player)
    player.cursor_stack.set_stack(nil)
		empire.clearText()
    player.teleport({x=0, y=0}, gui.surfaceName)
  end
end

function empire.showSelectedTiles(player)
	empireG.logF("showSelectedTiles", {player})
	local selectedTiles = empireG.gui[player.index].selectedTiles
	for i = 1,selectedTiles.len do
		local p = selectedTiles[i].p
		rendering.draw_rectangle{surface=player.surface, color={0.0, 1.0, 0.0, 0.25}, filled=true, left_top={x=p.x, y=p.y}, right_bottom={x=p.x+1,y=p.y+1}}
		rendering.draw_text{surface=player.surface, color={0.0, 0.0, 0.0, 1.0}, target={x=p.x+0.5, y=p.y+0.5}, text = tostring(i), alignment="center", vertical_alignment="middle"}
	end
end

function empire.addToSelectedTiles(event)
	empireG.logF("addToSelectedTiles", {event})
	local player = game.players[event.player_index]
	local selectedTiles = empireG.gui[event.player_index].selectedTiles
	local p = {x=math.floor(event.position.x), y=math.floor(event.position.y)}
	local selectedTileInfo = {pStr = tostring(p.x) .. "," .. tostring(p.y), p={x=p.x, y=p.y},index=selectedTiles.len+1}
	if selectedTiles[selectedTileInfo.pStr] ~= nil then
		local index = selectedTiles[selectedTileInfo.pStr].index
		selectedTiles[selectedTileInfo.pStr] = nil
		while selectedTiles[index+1] ~= nil do
			selectedTiles[index] = selectedTiles[index+1]
			selectedTiles[index].index = selectedTiles[index].index - 1
			index = index + 1
		end
		selectedTiles.len = selectedTiles.len - 1
		empire.clearText()
		empire.showFood({0,0})
		empire.showSelectedTiles(player)
		player.cursor_stack.set_stack({name = "empire_picker", count = 1})
		return
	end
	selectedTiles[selectedTileInfo.pStr] = selectedTileInfo
	selectedTiles[selectedTileInfo.index] = selectedTileInfo
	selectedTiles.len = selectedTiles.len + 1
	rendering.draw_rectangle{surface=player.surface, color={0.0, 1.0, 0.0, 0.25}, filled=true, left_top={x=p.x, y=p.y}, right_bottom={x=p.x+1,y=p.y+1}}
	rendering.draw_text{surface=player.surface, color={0.0, 0.0, 0.0, 1.0}, target={x=p.x+0.5, y=p.y+0.5}, text = tostring(selectedTileInfo.index), alignment="center", vertical_alignment="middle"}
	player.cursor_stack.set_stack({name = "empire_picker", count = 1})
end