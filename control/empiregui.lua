function empire.isGuiParent(element, parentName)
	empireG.logF("isGuiParent", {element, parentName})
	local parent = element
	while parent ~= nil do
		if parent.name == parentName then return true end
		parent = parent.parent
	end
	return false
end

function empire.handleOpenBuiltInGui(player, entity)
	empireG.logF("handleOpenBuiltInGui", {player, entity})
	if entity.name == "empire-world-map-tile" and empireG.worldMapTiles["" .. entity.position.x .. "," .. entity.position.y] ~= nil then 
		player.opened = nil
		player.teleport({x=0, y=0}, empireG.worldMapTiles["" .. entity.position.x .. "," .. entity.position.y].surface)
	elseif entity.name == "empire_vault" then
		player.opened = nil
		empire.openVaultGui(player, entity)
	elseif entity.name == "empire_huntingcabin" then
		player.opened = nil
		empire.openHuntingcabinGui(player, entity)
	elseif entity.name == "empire_storage" then
		empire.openStorageGui(player, entity)
	elseif entity.name == "empire_workshop" then
		empire.openWorkshopGui(player, entity)
	end
end

function empire.handleCloseGui(event)
	empireG.logF("handleCloseGui", {event})
	local player = game.get_player(event.player_index)
	if event.gui_type == defines.gui_type.entity then
		if event.entity.name == "empire_storage" then empire.closeStorageGui(player) end
		if event.entity.name == "empire_workshop" then empire.closeWorkshopGui(player) end
	elseif event.gui_type == defines.gui_type.custom then
		-- If you set player.opened to a frame factorio will not close that frame if a entity frame is opened, but it will rise this event
		-- letting you close the frame yourself
		if event.element.name == "vaultGui" then empire.closeVaultGui(player)
		elseif event.element.name == "huntingcabinGui" then empire.closeHuntingcabinGui(player) end
	end
end

function empire.handleGuiButtons(player, element)
	empireG.logF("handleGuiButtons", {player, element})
	if element.name == "goToWorldMap" then
		player.teleport({x=0, y=0}, game.surfaces["nauvis"])
	elseif element.name == "showFood" then
		empire.showFood({math.floor(player.position.x), math.floor(player.position.y)}, 180)
	elseif empire.isGuiParent(element, "storageFilterGui") then empire.handleStorageButtonPress(player, element)
	elseif empire.isGuiParent(element, "workshopProgressGui") then empire.handleWorkshopButtonPress(player, element)
	elseif empire.isGuiParent(element, "itemGui") then empire.handleItemGuiButtons(player, element)
	elseif empire.isGuiParent(element, "formSquad") then empire.handleFormSquadGuiButtons(player, element)
	elseif empire.isGuiParent(element, "vaultGui") then empire.handleVaultButtonPress(player, element)
	elseif empire.isGuiParent(element, "squadGui") then empire.handleSquadButtonPress(player, element)
	elseif empire.isGuiParent(element, "huntingcabinGui") then empire.handleHuntingcabinButtonPress(player, element)
	elseif empire.isGuiParent(element, "huntingPathGui") then empire.handleHuntingPathButtonPress(player, element)
	else
	end
end

function empire.showFood(position, time, radius)
	empireG.logF("showFood", {position, time, radius})
	if radius == nil then radius = 20 end
	for y=position[2]-radius,position[2]+radius do
		for x=position[1]-radius,position[1]+radius do
			if empireG.worldMapTiles[x .. "," .. y] ~= nil then
				empire.showText({x,y}, empireG.worldMapTiles[x .. "," .. y].maxFood)
			end
		end
	end
	if time ~= nil then empireG.addEvent(game.tick+time,empire.clearText,{}) end
end

function empire.showText(position, value)
	empireG.logF("showText", {position, value}, 1)
	if value == nil then return end
	rendering.draw_text{text=tostring(value),surface=game.surfaces["nauvis"],target={position[1]+0.5,position[2]+0.3},color={1,1,1},alignment="center",vertical_alignment="middle"}
	rendering.draw_text{text="",surface=game.surfaces["nauvis"],target={position[1]+0.5,position[2]+0.7},color={1,1,1},alignment="center",vertical_alignment="middle"}
end

function empire.clearText()
	empireG.logF("clearText", {})
	rendering.clear()
end