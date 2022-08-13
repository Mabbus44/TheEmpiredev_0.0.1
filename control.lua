require("util")
empireG = require("control/globals.lua")
local empire = require("control/empirelib.lua") 

script.on_init(function()
	empire.disableCrashsite()
end)

script.on_event(defines.events.on_player_created, function(event)
	empire.removeCharacter(game.get_player(event.player_index))
	empire.createWorldMap()
	for k, player in pairs(game.players) do
		player.get_main_inventory().resize(1)
		empire.createTopLeftGui(player)
		empire.createLeftGui(player)
		--empire.createStorageGui(player)
		--empire.createWarehouseGui(player)
	end
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
	empire.updateStatusGui(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_gui_opened, function(event)
	empire.handleOpenGui(game.get_player(event.player_index), event.entity)
end)

script.on_event(defines.events.on_gui_click, function(event)
	empire.handleGuiButtons(game.players[event.player_index], event.element)
end)

script.on_event(defines.events.on_chunk_generated, function(event)
	empire.generateChunk(event.surface, event.area)
end)

script.on_event(defines.events.on_player_crafted_item, function(event)
	empire.selectItemGhost(game.get_player(event.player_index), event.item_stack)
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
	empire.clearInventory(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_built_entity, function(event)
	empire.replaceGhosts(event.created_entity.surface)
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	empire.removeDeconstructed(event.entity.surface)
end)

script.on_event(defines.events.on_gui_closed, function(event)
	if event.element ~= nil and event.element.name == "centerGui" then empire.closeCenterGui(game.players[event.player_index]) end
end)

script.on_event(defines.events.on_tick, function(event)
	if event.tick >= empireG.runFunctionOnTick[1] then
		empire.gatherResources()
		empireG.runFunctionOnTick[1] = event.tick + 60
	end
	if event.tick >= empireG.runFunctionOnTick[2] then
		empire.adjustFoodAndPopulation()
		empireG.runFunctionOnTick[2] = event.tick + 60
	end
end)

script.on_event(defines.events.on_gui_value_changed, function(event)
	game.players[1].print(event.element.name)
	game.players[1].print(event.element.parent.name)
	local textfield = event.element.parent["sliderTextField"]
	textfield.text = tostring(event.element.slider_value)
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
	local fieldVal = tonumber(event.element.text)
	if fieldVal == nil then fieldVal = 0 end
	local slider = event.element.parent["slider"]
	slider.slider_value = fieldVal
end)