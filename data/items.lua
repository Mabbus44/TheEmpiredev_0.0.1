local iMap = require("data/entityToItemMap.lua")
-- New items
for entityName, i in pairs(iMap) do
	local item = table.deepcopy(data.raw[i[1]][i[2]])
	item.name = entityName
	item.localised_name = {entityName}
	if i[3] then item.place_result = entityName else item.place_result = nil end 
	data:extend{item}
end

-- Marker for picking worldmaptiles
local item = table.deepcopy(data.raw["capsule"]["defender-capsule"])
item.order = nil
item.capsule_action.attack_parameters.ammo_type.action = nil
item.name = "empire_picker"
data:extend{item}