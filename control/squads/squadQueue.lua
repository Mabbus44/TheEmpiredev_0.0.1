-- Partial gui. List of squads in queue
function empire.buildSquadQueueGui(playerId, baseFrame)
	empireG.logF("buildSquadQueueGui", {playerId, baseFrame})
	local squadQueueFlow = baseFrame.add{type = "flow", name = "squadQueueFlow", direction = "vertical"}
	squadQueueFlow.add{type="label", caption = {"squad_queue"}, name = "squadQueueCaption"}
  local first = true
	local sStats = empireG.surfaces[empireG.gui[playerId].entity.surface.name]
	for i, squad in pairs(sStats.squadQueue) do
		local squadFlow = squadQueueFlow.add{type = "flow", name = "flowSquad" .. tostring(i), direction = "vertical"}
		local people = squad.squad.empire_people
		if people == nil then people = 0 end
		local maxPeople = squad.template.empire_people
		if maxPeople == nil then maxPeople = 0 end
		local itemFlow = squadFlow.add{type = "flow", name = "empire_people"}
		itemFlow.add{type="label", caption=squad.name .. ": ", name = "itemName"}
		itemFlow.add{type="label", caption = {"empire_people"}, name = "peopleTrans"}
		itemFlow.add{type="label", caption= ": " .. tostring(people) .. "/" .. tostring(maxPeople), name = "peopleCount"}
		itemFlow.add{type = "sprite-button", sprite = "utility/close_white", name = "removeSquad"}
		if first then
			for name, count in pairs(squad.squad) do
				if name ~= "empire_people" then
					itemFlow = squadFlow.add{type = "flow", name = name}
					itemFlow.add{type="sprite", sprite="item/" .. empireG.iMap[name][2], name="itemSprite"}
					itemFlow.add{type="label", caption = {name}, name = "itemName"}
					itemFlow.add{type="label", caption=": " .. tostring(squad.squad[name]) .. "/" .. tostring(squad.template[name]), name = "itemCount"}
				end
			end
		end
		first = false
	end
end

function empire.handleSquadQueueButtonPress(player, element)
	empireG.logF("handleSquadQueueButtonPress", {player, element})
	if element.name == "removeSquad" then
		local squadIdString = element.parent.parent.name
		local squadId = tonumber(string.sub(squadIdString, string.len("flowSquad")+1, string.len(squadIdString)))
		local squadQueue = empireG.surfaces[empireG.gui[player.index].entity.surface.name].squadQueue
		table.remove(squadQueue, squadId)
		local baseFrame = element.parent.parent.parent.parent
		baseFrame.clear()
		empire.buildSquadQueueGui(player.index, baseFrame)
		return true
	end
	return false
end
