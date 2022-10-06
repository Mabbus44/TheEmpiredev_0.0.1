-- Partial gui. List of squads
function empire.buildSquadListGui(playerId, baseFrame, filters, selectFunction)
	empireG.logF("buildSquadListGui", {playerId, baseFrame, filters, selectFunction})
	if filters == nil then filters = {} end
	empireG.gui[playerId].selectFunction = selectFunction
	local squadListFlow = baseFrame.add{type = "flow", name = "sqadListFlow", direction = "vertical"}
	squadListFlow.add{type="label", caption = {"squads"}, name = "squadListCaption"}
	for i, squad in pairs(empireG.squadList) do
		local showSquad = true
		for key, val in pairs(filters) do
			if squad[key] ~= val then showSquad = false end
		end
		if showSquad == true then
			local itemFlow = squadListFlow.add{type = "flow", name = "flowSquad" .. tostring(i)}
			local people = squad.squad.empire_people
			if people == nil then people = 0 end
			local maxPeople = squad.template.empire_people
			if maxPeople == nil then maxPeople = 0 end
			itemFlow.add{type="button", caption=squad.name .. ": ", name = "openSquadInfo"}
			itemFlow.add{type="label", caption = {"empire_people"}, name = "peopleTrans"}
			itemFlow.add{type="label", caption= ": " .. tostring(people) .. "/" .. tostring(maxPeople) .. " ", name = "peopleCount"}
			itemFlow.add{type="label", caption = {"home_settlement"}, name = "homeSettlementTrans"}
			itemFlow.add{type="label", caption= ": " .. squad.home .. " ", name = "homeSettlemnet"}
			itemFlow.add{type="label", caption = {"task"}, name = "taskTrans"}
			itemFlow.add{type="label", caption= ": " .. squad.task .. " ", name = "task"}
			itemFlow.add{type="label", caption = {"status"}, name = "statusTrans"}
			itemFlow.add{type="label", caption= ": " .. squad.status .. " ", name = "status"}
			if selectFunction ~= nil and squad.task == "none" and squad.status == "idle" then
				itemFlow.add{type="button", caption={"select"}, name = "selectFunction"}
			end
		end
	end
end

function empire.handleSquadListButtonPress(player, element)
	empireG.logF("handleSquadListButtonPress", {player, element})
	if element.name == "openSquadInfo" then
		local squadIdString = element.parent.name
		local squadId = tonumber(string.sub(squadIdString, string.len("flowSquad")+1, string.len(squadIdString)))
		local squadList = empireG.squadList
		empire.openSquadGui(player, squadList[squadId])
		return true
	elseif element.name == "selectFunction" then
		local squadIdString = element.parent.name
		local squadId = tonumber(string.sub(squadIdString, string.len("flowSquad")+1, string.len(squadIdString)))
		local squadList = empireG.squadList
		empireG.gui[player.index].selectFunction(player, squadList[squadId])
		return true
	end
	return false
end
