local empire = {}

function empire.createTopLeftGui(player)
	local frame = player.gui.top.add{type="frame"}
	local button = frame.add{type="button", caption="world map", name = "goToWorldMap"}
end

function empire.createLeftGui(player)
	local frame = player.gui.left.add{type="frame", name = "statusGui"}
	frame.caption = "nothing selected"
	local label = frame.add{type="label", caption="", name = "stats"}
	label.style.single_line = false
end

function empire.createStorageGui(player)
	local frame = player.gui.relative.add{type="frame", name = "storageFilterGui"}
	frame.anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.bottom, names = {"empire-storage", "empire-greenhouse"}}
	frame.caption = {"filters"}
	frame.add{type="sprite-button", sprite="empire-general", name="general", number = 17}
	frame.add{type="sprite-button", sprite="empire-add", name="addItem"}
	frame.add{type="slider", name="slider"}
	frame.add{type="textfield", numeric=true, name="sliderTextField"}
	--local label = frame.add{type="label", caption="", name = "testlabel"}
end

function empire.createWarehouseGui(player)
end

function empire.updateStatusGui(player)
	if player.selected == nil or not string.find(player.selected.name, "empire-") then
		player.gui.left["statusGui"].caption = "nothing selected"
		player.gui.left["statusGui"]["stats"].caption = ""
		return
	end
	local caption = player.selected.localised_name
	local stats = "x: " .. player.selected.position.x .. ", y: " .. player.selected.position.y
	log(player.selected.name)
	if player.selected.name == "empire-world-map-tile" then
		local tileStats = empireG.worldMapTiles["" .. player.selected.position.x .. "," .. player.selected.position.y]
		if tileStats ~= nil and tileStats.surface ~= nil then
			stats = stats .. "\n" .. tileStats.surface.name
		end
	elseif player.selected.name == "empire-vault" then
		local sData = empireG.surfaces[player.selected.surface.name]
		stats = stats .. "\nPopulation " .. sData.population .. "/" .. sData.maxPopulation
		stats = stats .. "\nPopdec " .. string.format("%.3f",sData.populationDecimals)
		stats = stats .. "\nFood reserves " .. string.format("%.3f",sData.foodReserves) .. "/" .. string.format("%.3f",sData.maxReservePerPerson*sData.population)
		stats = stats .. "\nPopulation groth " .. string.format("%.2f",sData.populationGroth)
		if sData.grothEnabled then 
			stats = stats .. "\nGroth enabled"
		else
			stats = stats .. "\nGroth disabled"
		end
	else
		local entityStats = empireG.entityStats[player.selected.unit_number]
		if entityStats.paused then stats = stats .. "\nPaused" end
		if entityStats.workerCount ~= nil then stats = stats .. "\nWorkers " .. entityStats.workerCount .. "/" .. entityStats.requiredWorkers end
		if entityStats.enabled then stats = stats .. "\nEnabled" else stats = stats .. "\nDisabled" end
	end
	player.gui.left["statusGui"].caption = caption
	player.gui.left["statusGui"]["stats"].caption = stats
end

function empire.openCenterGui(player, caption, text)
	empire.closeCenterGui(player)
	local root = player.gui.screen	
	local frame = root.add {type="frame", name="centerGui", direction="vertical"}
	player.opened = frame
	frame.location = {800,400}
	local title_flow = frame.add{type = "flow", name = "title_flow"}
  local title = title_flow.add{type = "label", caption = caption, style = "frame_title"}
  title.drag_target = frame
  local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "closeCenterGui"}
	local label = frame.add{type="label", caption=text}
	label.drag_target = frame
end

function empire.openVaultGui(player, vault)
	local stats = empireG.surfaces[vault.surface.name]
	local text = "Population " .. stats.population .. "/" .. stats.maxPopulation
	empire.openCenterGui(player, vault.localised_name, text)
end

function empire.closeCenterGui(player)
	if player.gui.screen["centerGui"] ~= nil then player.gui.screen["centerGui"].destroy() end
	player.opened = nil
end

function empire.handleGuiButtons(player, element)
	if element.name == "closeCenterGui" then
		empire.closeCenterGui(player)
	elseif element.name == "goToWorldMap" then
		player.teleport({x=0, y=0}, game.surfaces["worldMap"])
	end
end

function empire.handleOpenGui(player, entity)
	if entity == nil then return end
	if entity.name == "empire-world-map-tile" and empireG.worldMapTiles["" .. entity.position.x .. "," .. entity.position.y] ~= nil then 
		player.opened = nil
		player.teleport({x=0, y=0}, empireG.worldMapTiles["" .. entity.position.x .. "," .. entity.position.y].surface)
	elseif entity.name == "empire-vault" then
		player.opened = nil
		empire.openVaultGui(player, entity)
	elseif entity.name == "empire-storage" then
		empire.createStorageGui(player)
	end
end

return empire