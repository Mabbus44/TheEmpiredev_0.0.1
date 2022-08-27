local empire = {}

function empire.openStatusGui(player)
	local frame = player.gui.left.add{type="frame", name = "statusGui"}
	frame.caption = "nothing selected"
	local label = frame.add{type="label", caption="", name = "stats"}
	label.style.single_line = false
end

function empire.updateStatusGui(player)
	if player.selected == nil or not string.find(player.selected.name, "empire-") then
		player.gui.left["statusGui"].caption = "nothing selected"
		player.gui.left["statusGui"]["stats"].caption = ""
		return
	end
	local caption = player.selected.localised_name
	local stats = "x: " .. player.selected.position.x .. ", y: " .. player.selected.position.y
	if string.find(player.selected.name, "empire-") then stats = stats .. "\nUnit number: " .. player.selected.unit_number end
	if player.selected.name == "empire-world-map-tile" then
		local tileStats = empireG.worldMapTiles["" .. player.selected.position.x .. "," .. player.selected.position.y]
		if tileStats ~= nil then
			if tileStats.surface ~= nil then
				stats = stats .. "\n" .. tileStats.surface.name
			end
			if tileStats.maxFood ~= nil then stats = stats .. "\nFood: " .. tileStats.maxFood end
			if tileStats.biterCount ~= nil then stats = stats .. "\nBiters: " .. tileStats.biterCount end
			if tileStats.biterLevel ~= nil then stats = stats .. "\nBiter level: " .. tileStats.biterLevel end
			
		end
	elseif player.selected.name == "empire_vault" then
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
		if entityStats ~= nil then
			if entityStats.paused then stats = stats .. "\nPaused" end
			if entityStats.workerCount ~= nil then stats = stats .. "\nWorkers " .. entityStats.workerCount .. "/" .. entityStats.requiredWorkers end
			if entityStats.enabled then stats = stats .. "\nEnabled" else stats = stats .. "\nDisabled" end
			if entityStats.buildingStats then
				stats = stats .. "\nConstruction status: " .. entityStats.buildingStats.status
				if entityStats.buildingStats.startTick then stats = stats .. "\nStart tick: " .. entityStats.buildingStats.startTick end
				if entityStats.buildingStats.buildTime then stats = stats .. "\nBuild time: " .. entityStats.buildingStats.buildTime end
			end
		end
	end
	player.gui.left["statusGui"].caption = caption
	player.gui.left["statusGui"]["stats"].caption = stats
end

return empire