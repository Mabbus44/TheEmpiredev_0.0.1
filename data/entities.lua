-- Unbuildable terrain
data.raw["tile"]["red-desert-0"].collision_mask =  {"object-layer", "ground-tile"}

local vault = table.deepcopy(data.raw["container"]["wooden-chest"])
vault.name = "empire_vault"
vault.localised_name = {"empire_vault"}
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
vault.inventory_type = "with_filters_and_bar"
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
storage.name = "empire_storage"
storage.localised_name = {"empire_storage"}
storage.minable = nil
storage.inventory_type = "with_filters_and_bar"
data:extend{storage}

local blocked = table.deepcopy(data.raw["container"]["steel-chest"])
blocked.name = "empire_blocked"
blocked.localised_name = {"empire_blocked"}
data:extend{blocked}

local mechanicalBelt = table.deepcopy(data.raw["transport-belt"]["transport-belt"])
mechanicalBelt.name = "empire_mechanical_belt"
mechanicalBelt.localised_name = {"empire_mechanical_belt"}
mechanicalBelt.minable = nil
mechanicalBelt.next_upgrade = nil
data:extend{mechanicalBelt}

local inserter = table.deepcopy(data.raw["inserter"]["inserter"])
inserter.name = "empire_inserter"
inserter.localised_name = {"empire_inserter"}
inserter.minable = nil
inserter.next_upgrade = nil
inserter.next_upgrade = nil
inserter.energy_source = {type = "void"}
inserter.allow_custom_vectors = true
data:extend{inserter}

local ironOre = data.raw["resource"]["iron-ore"]
ironOre.infinite = true
ironOre.minimum = 1
ironOre.infinite_depletion_amount = 0

local miningDrill = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"])
miningDrill.name = "empire_mining_drill"
miningDrill.localised_name = {"empire_mining_drill"}
miningDrill.minable = nil
miningDrill.next_upgrade = nil
miningDrill.energy_source = {type = "void"}
data:extend{miningDrill}

local furnace = table.deepcopy(data.raw["furnace"]["stone-furnace"])
furnace.name = "empire_furnace"
furnace.localised_name = {"empire_furnace"}
furnace.minable = nil
furnace.next_upgrade = nil
furnace.energy_source = {type = "void"}
data:extend{furnace}

local workshop = table.deepcopy(data.raw["container"]["wooden-chest"])
workshop.name = "empire_workshop"
workshop.localised_name = {"empire_workshop"}
workshop.minable = nil
workshop.next_upgrade = nil
workshop.energy_source = {type = "void"}
workshop.picture = {filename="__TheEmpiredev__/graphics/workshop.png", width = 96, height = 103}
workshop.collision_box = data.raw["assembling-machine"]["assembling-machine-1"].collision_box
workshop.selection_box = data.raw["assembling-machine"]["assembling-machine-1"].selection_box
--workshop.selection_box = {{0, 0}, {2, 2}}
workshop.inventory_type = "with_filters_and_bar"
data:extend{workshop}

local workshopOutput = table.deepcopy(workshop)
workshopOutput.selection_box = nil
--workshopOutput.selection_box = {{-2, -2}, {0, 0}}
workshopOutput.localised_name = {"empire_workshop_output"}
workshopOutput.picture = {filename="__core__/graphics/empty.png", width = 1, height = 1}
--workshopOutput.picture = {filename="__TheEmpiredev__/graphics/workshop.png", width = 96, height = 103}
workshopOutput.name = "empire_workshop_output"
data:extend{workshopOutput}

local greenhouse = table.deepcopy(vault)
greenhouse.name = "empire_greenhouse"
greenhouse.localised_name = {"empire_greenhouse"}
greenhouse.collision_box = {{-1.2, -1.2}, {1.2, 1.2}}
greenhouse.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
greenhouse.picture = {filename="__TheEmpiredev__/graphics/greenhouse.png", width = 96, height = 86}
greenhouse.energy_source = {type = "void"}
data:extend{greenhouse}

local huntingcabin = table.deepcopy(vault)
huntingcabin.name = "empire_huntingcabin"
huntingcabin.localised_name = {"empire_huntingcabin"}
huntingcabin.collision_box = data.raw["assembling-machine"]["assembling-machine-1"].collision_box
huntingcabin.selection_box = data.raw["assembling-machine"]["assembling-machine-1"].selection_box
huntingcabin.picture = {filename="__TheEmpiredev__/graphics/workshop.png", width = 96, height = 103}
huntingcabin.energy_source = {type = "void"}
data:extend{huntingcabin}

local squad = table.deepcopy(data.raw["unit"]["small-biter"])
squad.name = "empire_squad"
squad.localised_name = {"empire_squad"}
squad.corpse = nil
squad.affected_by_tiles = nil
squad.ai_settings = nil
squad.alternative_attacking_frame_sequence = nil
squad.can_open_gates = nil
squad.dying_sound = nil
squad.has_belt_immunity = nil
squad.light = nil
squad.max_pursue_distance = nil
squad.min_pursue_time = nil
squad.move_while_shooting = nil
squad.radar_range = nil
squad.render_layer = nil
squad.rotation_speed = nil
squad.running_sound_animation_positions = nil
squad.spawning_time_modifier = nil
squad.walking_sound = nil
data:extend{squad}
