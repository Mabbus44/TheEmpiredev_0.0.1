-- New items
local item = table.deepcopy(data.raw["item"]["transport-belt"])
item.name = "empire-mechanical-belt"
item.localised_name = {"empire-mechanical-belt"}
item.place_result = "empire-mechanical-belt"
data:extend{item}

item = table.deepcopy(data.raw["item"]["wooden-chest"])
item.name = "empire-storage"
item.localised_name = {"empire-storage"}
item.place_result = "empire-storage"
data:extend{item}

item = table.deepcopy(data.raw["item"]["inserter"])
item.name = "empire-inserter"
item.localised_name = {"empire-inserter"}
item.place_result = "empire-inserter"
data:extend{item}

item = table.deepcopy(data.raw["item"]["burner-mining-drill"])
item.name = "empire-mining-drill"
item.localised_name = {"empire-mining-drill"}
item.place_result = "empire-mining-drill"
data:extend{item}

item = table.deepcopy(data.raw["item"]["stone-furnace"])
item.name = "empire-furnace"
item.localised_name = {"empire-furnace"}
item.place_result = "empire-furnace"
data:extend{item}

item = table.deepcopy(data.raw["item"]["assembling-machine-1"])
item.name = "empire-workshop"
item.localised_name = {"empire-workshop"}
item.place_result = "empire-workshop"
data:extend{item}

item = table.deepcopy(data.raw["item"]["lab"])
item.name = "empire-greenhouse"
item.localised_name = {"empire-greenhouse"}
item.place_result = "empire-greenhouse"
data:extend{item}

item = table.deepcopy(data.raw["capsule"]["raw-fish"])
item.name = "empire-food"
item.localised_name = {"empire-food"}
data:extend{item}
