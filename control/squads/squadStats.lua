-- Window. Stats for one squad
function empire.openSquadGui(player, squad)
	empireG.logF("openSquadGui", {player, squad})
	empire.closeSquadGui(player)
	local root = player.gui.screen	
	local frame = root.add {type="frame", name="squadGui", direction="vertical"}
	frame.location = {800,400}
	local title_flow = frame.add{type = "flow", name = "title_flow"}
  local title = title_flow.add{type = "label", caption = squad.name, style = "frame_title"}
  title.drag_target = frame
  local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "closeSquadGui"}
	
	local squadFlow = frame.add{type = "flow", name = "squadFlow", direction = "vertical"}
	local people = squad.squad.empire_people
	if people == nil then people = 0 end
	local maxPeople = squad.template.empire_people
	if maxPeople == nil then maxPeople = 0 end
	local itemFlow = squadFlow.add{type = "flow", name = "empire_people"}
	itemFlow.add{type="label", caption=squad.name .. ": ", name = "itemName"}
	itemFlow.add{type="label", caption = {"empire_people"}, name = "peopleTrans"}
	itemFlow.add{type="label", caption= ": " .. tostring(people) .. "/" .. tostring(maxPeople), name = "peopleCount"}
	for name, count in pairs(squad.squad) do
		if name ~= "empire_people" then
			itemFlow = squadFlow.add{type = "flow", name = name}
			itemFlow.add{type="sprite", sprite="item/" .. empireG.iMap[name][2], name="itemSprite"}
			itemFlow.add{type="label", caption = {name}, name = "itemName"}
			itemFlow.add{type="label", caption=": " .. tostring(squad.squad[name]) .. "/" .. tostring(squad.template[name]), name = "itemCount"}
		end
	end
end

function empire.handleSquadButtonPress(player, element)
	empireG.logF("handleSquadButtonPress", {player, element})
	if element.name == "closeSquadGui" then
		empire.closeSquadGui(player)
	end
end

function empire.closeSquadGui(player)
	empireG.logF("closeSquadGui", {player})
	if player.gui.screen["squadGui"] ~= nil then player.gui.screen["squadGui"].destroy() end
end
