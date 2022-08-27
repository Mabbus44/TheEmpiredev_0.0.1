local empire = {}

function empire.openVaultGui(player, vault)
	local stats = empireG.surfaces[vault.surface.name]
	local text = "Population " .. stats.population .. "/" .. stats.maxPopulation
	local caption = vault.localised_name	
	empire.closeVaultGui(player)
	local root = player.gui.screen	
	local frame = root.add {type="frame", name="vaultGui", direction="vertical"}
	player.opened = frame
	frame.location = {800,400}
	local title_flow = frame.add{type = "flow", name = "title_flow"}
  local title = title_flow.add{type = "label", caption = caption, style = "frame_title"}
  title.drag_target = frame
  local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "closeVaultGui"}
	local label = frame.add{type="label", caption=text}
	label.drag_target = frame
end

function empire.closeVaultGui(player)
	if player.gui.screen["vaultGui"] ~= nil then player.gui.screen["vaultGui"].destroy() end
	player.opened = nil
end

return empire