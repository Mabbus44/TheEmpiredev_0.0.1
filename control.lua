require("util")
require("control/empirelib.lua") 

script.on_init(function()
	--empire.disableCrashsite()
	-- If I generate the world map on tick 0 it already order chunk generation with old settings, so I do it on tick 1
	empireG.addEvent(1, empire.generateWorldMap, {})
end)

script.on_event(defines.events.on_player_created, function(event)
	empireG.logF("on_player_created", {event})
	local player = game.get_player(event.player_index)
	empire.removeCharacter(player)
	empire.openTopGui(player)
	empire.openStatusGui(player)
	empireG.gui[event.player_index] = {}
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
	empire.updateStatusGui(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_gui_opened, function(event)
	empireG.logF("on_gui_opened", {event})
	if event.gui_type == defines.gui_type.entity then
		empire.handleOpenBuiltInGui(game.get_player(event.player_index), event.entity)
	end
end)

script.on_event(defines.events.on_gui_closed, function(event)
	empireG.logF("on_gui_closed", {event})
	empire.handleCloseGui(event)
end)

script.on_event(defines.events.on_gui_click, function(event)
	empire.handleGuiButtons(game.players[event.player_index], event.element)
end)

script.on_event(defines.events.on_gui_value_changed, function(event)
	empireG.logF("on_gui_value_changed", {event})
	if empire.isGuiParent(event.element, "ILBValueFlow") then empire.handleItemListBuilderValueChange(event) end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
	empireG.logF("on_gui_text_changed", {event})
	if empire.isGuiParent(event.element, "ILBValueFlow") then empire.handleItemListBuilderTextChange(event) end
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

script.on_event(defines.events.on_player_used_capsule, function(event)
	empireG.logF("on_player_used_capsule", {event})
	if event.item.name=="empire_picker" then
		empire.addToSelectedTiles(event)
	end
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	empire.removeDeconstructed(event.entity.surface)
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
	empire.clearInventory(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
	empireG.logF("on_player_rotated_entity", {event})
	if event.entity.name == "empire_inserter" then empireG.addEvent(game.tick+1, empire.inserterChangeDrop, {{event.entity}}) end
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
	empireG.logF("on_entity_destroyed", {event})
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
