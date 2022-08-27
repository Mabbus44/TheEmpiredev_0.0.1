require("util")
empireG = require("control/globals.lua")
iMap = require("data/entityToItemMap.lua")
require("control/empirelib.lua") 

script.on_init(function()
	--empire.disableCrashsite()
	-- If I generate the world map on tick 0 it already order chunk generation with old settings, so I do it on tick 1
	empireG.addEvent(1, empire.generateWorldMap, {})
end)

script.on_event(defines.events.on_player_created, function(event)
	empire.removeCharacter(game.get_player(event.player_index))
	for k, player in pairs(game.players) do
		empire.openTopGui(player)
		empire.openStatusGui(player)
	end
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
	empire.updateStatusGui(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_gui_opened, function(event)
	empire.handleOpenGui(game.get_player(event.player_index), event.entity)
end)

script.on_event(defines.events.on_gui_closed, function(event)
	empire.handleCloseGui(game.get_player(event.player_index), event.entity, event.element, event.gui_type)
end)

script.on_event(defines.events.on_gui_click, function(event)
	empire.handleGuiButtons(game.players[event.player_index], event.element)
end)

script.on_event(defines.events.on_gui_value_changed, function(event)
	if empire.isGuiParent(event.element, "storageFilterGui") then empire.handleStorageValueChange(event) end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
	if empire.isGuiParent(event.element, "storageFilterGui") then empire.handleStorageTextChange(event) end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
	empire.generateChunk(event.surface, event.area)
end)

script.on_event(defines.events.on_built_entity, function(event)
	empire.replaceGhosts(event.created_entity.surface)
end)

script.on_event(defines.events.on_player_crafted_item, function(event)
	empire.selectItemGhost(game.get_player(event.player_index), event.item_stack)
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	empire.removeDeconstructed(event.entity.surface)
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
	empire.clearInventory(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
	if event.entity.name == "empire_inserter" then empireG.addEvent(game.tick+1, empire.inserterChangeDrop, {{event.entity}}) end
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
	log(empireG.log(event.unit_number))
	if event.unit_number == nil then return end
	local eStats = empireG.entityStats[event.unit_number]
	if eStats == nil then return end
	if eStats.outputEntity ~= nil and eStats.outputEntity.name == "empire_workshop_output" then 
		eStats.outputEntity.destroy()
	end
end)

script.on_event(defines.events.on_tick, function(event)
	empireG.callEvent(event.tick)
	if event.tick >= empireG.runFunctionOnTick[1] then
		empire.gatherResources()
		empire.adjustFoodAndPopulation()
		empire.restartWorkshops()
		empireG.runFunctionOnTick[1] = event.tick + 60
	end
	for playerIndex, playerGui in pairs(empireG.gui) do
		if playerGui.buildingStatus and playerGui.buildingStatus.status == "building" then
			game.players[playerIndex].gui.relative.workshopProgressGui.progressFlow.progressbar.value = (game.tick - playerGui.buildingStatus.startTick) / playerGui.buildingStatus.buildTime
		end
	end
end)
