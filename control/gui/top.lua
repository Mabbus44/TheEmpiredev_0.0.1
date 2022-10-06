function empire.openTopGui(player)
	empireG.logF("openTopGui", {player})
	local frame = player.gui.top.add{type="frame"}
	local button = frame.add{type="button", caption={"world_map"}, name = "goToWorldMap"}
	local button = frame.add{type="button", caption={"show_food"}, name = "showFood"}
end