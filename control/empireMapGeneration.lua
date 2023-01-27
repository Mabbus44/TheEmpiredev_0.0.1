function empire.generateWorldMap()
	empireG.logF("generateWorldMap", {})
	local surface = game.surfaces["nauvis"]
	empireG.worldMapCreated = true
	surface.clear(true)
	local mgs = surface.map_gen_settings

	mgs.autoplace_settings["entity"] = {treat_missing_as_default = false, settings = {}}
	mgs.autoplace_settings["tile"] = {treat_missing_as_default = false, settings = {["dirt-1"] = 0, ["red-desert-0"] = 0, ["sand-1"] = 0, ["sand-2"] = 0, ["sand-3"] = 0, ["grass-1"] = 0, ["grass-2"] = 0, ["grass-3"] = 0, ["grass-4"] = 0}}
	mgs.cliff_settings = {cliff_elevation_0 = 1024}
	mgs.property_expression_names["tile:grass-1:probability"] = "dryLvl1"
	mgs.property_expression_names["tile:grass-2:probability"] = "dryLvl2"
	mgs.property_expression_names["tile:grass-3:probability"] = "dryLvl3"
	mgs.property_expression_names["tile:grass-4:probability"] = "dryLvl4"
	mgs.property_expression_names["tile:sand-3:probability"] = "dryLvl5"
	mgs.property_expression_names["tile:sand-2:probability"] = "dryLvl6"
	mgs.property_expression_names["tile:sand-1:probability"] = "dryLvl7"
	mgs.property_expression_names["tile:red-desert-0:probability"] = "montain"
	mgs.property_expression_names["tile:dirt-1:probability"] = "forest"
	
	surface.map_gen_settings = mgs
end

function empire.worldMapChunkGenerated(surface, minY, maxY, minX, maxX)
	empireG.logF("worldMapChunkGenerated", {surface, minY, maxY, minX, maxX}, 2)
	for y = minY, maxY do
		for x = minX, maxX do
			local surfaceName = surface.get_tile(x, y).name
			if string.find(surfaceName, "dirt") then
				local num = math.random(1,9)
				surface.create_entity{name="tree-0" .. tostring(num), position = {x=x, y=y}, force = "neutral"}
			end
			if string.find(surfaceName, "red") then
				local num = math.random(1,7)
				if num == 1 then surface.create_entity{name="rock-big", position = {x=x, y=y}, force = "neutral"} end
				if num == 2 then surface.create_entity{name="rock-huge", position = {x=x, y=y}, force = "neutral"} end
				if num == 3 then surface.create_entity{name="sand-rock-big", position = {x=x, y=y}, force = "neutral"} end
			end
			if x==0 and y == 0 then


				local newSquad = surface.create_entity{name="empire_squad", position = {x=3, y=3}, force = game.forces["player"]}
				newSquad.add_autopilot_destination({x=10, y=0})
				--[[local newSquad = surface.create_entity{name="empire_squad", position = {x=5, y=3}, force = game.forces["player"]}
				newSquad.set_distraction_command{type=defines.command.stop}
				local newSquad = surface.create_entity{name="empire_squad", position = {x=5, y=5}, force = game.forces["enemy"]}
				newSquad.set_distraction_command{type=defines.command.stop, distraction=defines.distraction.none}--]]
				

				local newSurface = empire.createSettlementMap(100, {x=0, y=0})
				local tile = surface.create_entity{name="empire-world-map-tile", position = {x=0, y=0}, force = "neutral"}
				empireG.worldMapTiles["" .. tile.position.x .. "," .. tile.position.y] = {surface = newSurface}
			--elseif x==2 and y == 2 then
				--local newSurface = empire.createSettlementMap(70, {x=2, y=2})
				--local tile = surface.create_entity{name="empire-world-map-tile", position = {x=2, y=2}, force = "neutral"}
				--empireG.worldMapTiles["" .. tile.position.x .. "," .. tile.position.y] = {surface = newSurface}
			else
				--local tile = surface.create_entity{name="empire-world-map-tile", position = {x=0, y=0}, force = "neutral"}
				--tile.position.
				local tileKey = "" .. x .. "," .. y
				empireG.worldMapTiles[tileKey] = {biterCount = 0, biterLevel = 1}
				empireG.tileCount = empireG.tileCount + 1
				if string.find(surfaceName, "dirt") then empireG.worldMapTiles[tileKey].maxFood = 200
				elseif surfaceName == "grass-1" then empireG.worldMapTiles[tileKey].maxFood = 100
				elseif surfaceName == "grass-2" then empireG.worldMapTiles[tileKey].maxFood = 80
				elseif surfaceName == "grass-3" then empireG.worldMapTiles[tileKey].maxFood = 60
				elseif surfaceName == "grass-4" then empireG.worldMapTiles[tileKey].maxFood = 50
				elseif surfaceName == "sand-3" then empireG.worldMapTiles[tileKey].maxFood = 20
				elseif surfaceName == "sand-2" then empireG.worldMapTiles[tileKey].maxFood = 10
				elseif surfaceName == "sand-1" then empireG.worldMapTiles[tileKey].maxFood = 0
				elseif string.find(surfaceName, "red") then empireG.worldMapTiles[tileKey].maxFood = 20
				end
			end
		end
	end
end
