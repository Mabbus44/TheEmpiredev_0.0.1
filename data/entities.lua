-- Unbuildable terrain
data.raw["tile"]["red-desert-0"].collision_mask =  {"object-layer", "ground-tile"}

local vault = table.deepcopy(data.raw["container"]["wooden-chest"])
vault.name = "empire-vault"
vault.localised_name = {"empire-vault"}
vault.damaged_trigger_effect = nil
vault.minable = nil
vault.vehicle_impact_sound = nil
vault.max_health = 1000
vault.corpse = nil
vault.dying_explosion = nil
vault.fast_replaceable_group = nil
vault.open_sound = nil
vault.close_sound = nil
vault.circuit_wire_connection_point = nil
vault.circuit_connector_sprites = nil
vault.circuit_wire_max_distance = nil
vault.picture = {filename="__TheEmpiredev__/graphics/vault.png", width = 128, height = 94}
vault.collision_box = {{-1.7, -1.7}, {1.7, 1.7}}
vault.selection_box = {{-2, -2}, {2, 2}}
data:extend{vault}

local worldMapTile = table.deepcopy(vault)
worldMapTile.name = "empire-world-map-tile"
worldMapTile.flags = nil
worldMapTile.collision_box = nil
worldMapTile.max_health = nil
worldMapTile.selection_box = {{0, 0}, {1, 1}}
worldMapTile.picture = {filename="__core__/graphics/empty.png", width = 1, height = 1}
data:extend{worldMapTile}

local storage = table.deepcopy(data.raw["container"]["wooden-chest"])
storage.name = "empire-storage"
storage.localised_name = {"empire-storage"}
storage.minable = nil
data:extend{storage}

local mechanicalBelt = table.deepcopy(data.raw["transport-belt"]["transport-belt"])
mechanicalBelt.name = "empire-mechanical-belt"
mechanicalBelt.localised_name = {"empire-mechanical-belt"}
mechanicalBelt.minable = nil
mechanicalBelt.next_upgrade = nil
data:extend{mechanicalBelt}

local inserter = table.deepcopy(data.raw["inserter"]["inserter"])
inserter.name = "empire-inserter"
inserter.localised_name = {"empire-inserter"}
inserter.minable = nil
inserter.next_upgrade = nil
inserter.next_upgrade = nil
inserter.energy_source = {type = "void"}
data:extend{inserter}

local ironOre = data.raw["resource"]["iron-ore"]
ironOre.infinite = true
ironOre.minimum = 1
ironOre.infinite_depletion_amount = 0

local miningDrill = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"])
miningDrill.name = "empire-mining-drill"
miningDrill.localised_name = {"empire-mining-drill"}
miningDrill.minable = nil
miningDrill.next_upgrade = nil
miningDrill.energy_source = {type = "void"}
data:extend{miningDrill}

local furnace = table.deepcopy(data.raw["furnace"]["stone-furnace"])
furnace.name = "empire-furnace"
furnace.localised_name = {"empire-furnace"}
furnace.minable = nil
furnace.next_upgrade = nil
furnace.energy_source = {type = "void"}
data:extend{furnace}

local workshop = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
workshop.name = "empire-workshop"
workshop.localised_name = {"empire-workshop"}
workshop.minable = nil
workshop.next_upgrade = nil
workshop.energy_source = {type = "void"}
data:extend{workshop}

local greenhouse = table.deepcopy(vault)
greenhouse.name = "empire-greenhouse"
greenhouse.localised_name = {"empire-greenhouse"}
greenhouse.collision_box = {{-1.2, -1.2}, {1.2, 1.2}}
greenhouse.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
greenhouse.picture = {filename="__TheEmpiredev__/graphics/greenhouse.png", width = 96, height = 86}
greenhouse.energy_source = {type = "void"}
data:extend{greenhouse}