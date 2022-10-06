-- Partial gui. List of squad-templates
function empire.buildSquadTemplatesGui(playerId, baseFrame)
	empireG.logF("buildSquadTemplatesGui", {playerId, baseFrame})
	local squadTemplatesFlow = baseFrame.add{type = "flow", name = "sqadTemplatesFlow", direction = "vertical"}
	squadTemplatesFlow.add{type="label", caption = {"squad_templates"}, name = "squadTemplatesCaption"}
	for i, squad in pairs(empireG.squadTemplates) do
		local itemFlow = squadTemplatesFlow.add{type = "flow", name = "flowSquad" .. tostring(i)}
		local people = squad.template.empire_people
		itemFlow.add{type="label", caption=squad.name .. ": ", name = "itemName"}
		itemFlow.add{type="label", caption = {"empire_people"}, name = "peopleTrans"}
		itemFlow.add{type="label", caption= ": " .. tostring(people) .. " ", name = "peopleCount"}
		local itemCount = 0
		for name, count in pairs(squad.template) do
			itemCount = itemCount + 1
			if itemCount == 4 then break end
			if name ~= "empire_people" then
				itemFlow.add{type="sprite", sprite="item/" .. empireG.iMap[name][2], name=name .. "itemSprite"}
				itemFlow.add{type="label", caption = {name}, name = name .. "itemName"}
				itemFlow.add{type="label", caption = ": " .. tostring(squad.template[name]) .. " ", name = name .. "itemCount"}
			end
		end
		if itemCount == 4 then
			itemFlow.add{type="label", caption = "... ", name = "dotdotdot"}
		end
		itemFlow.add{type="button", caption={"create_squad"}, name = "createSquad"}
	end
end

function empire.handleSquadTemplatesButtonPress(player, element)
	empireG.logF("handleSquadTemplatesButtonPress", {player, element})
	if element.name == "createSquad" then
		local squadIdString = element.parent.name
		local squadId = tonumber(string.sub(squadIdString, string.len("flowSquad")+1, string.len(squadIdString)))
		local surfaceName = empireG.gui[player.index].entity.surface.name
		local newSquad = empire.createSquad(empireG.squadTemplates[squadId].name, surfaceName, empireG.squadTemplates[squadId].template)
		local sStats = empireG.surfaces[surfaceName]
		table.insert(sStats.squadQueue, newSquad)
		if #(sStats.squadQueue) == 1 then empire.resupplySquad(empireG.gui[player.index].entity.surface) end
		return true
	end
	return false
end
