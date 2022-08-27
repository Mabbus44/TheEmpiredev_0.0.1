local iMap = require("data/entityToItemMap.lua")
-- New items
for entityName, i in pairs(iMap) do
	local item = table.deepcopy(data.raw[i[1]][i[2]])
	item.name = entityName
	item.localised_name = {entityName}
	if i[1] == "item" then item.place_result = entityName end 
	data:extend{item}
end
