-- New recipes for workshops
local recipe = table.deepcopy(data.raw["recipe"]["transport-belt"])
recipe.name = "empire_mechanical_belt"
recipe.localised_name = {"empire_mechanical_belt"}
recipe.result = "empire_mechanical_belt"
recipe.enabled = true
recipe.energy_required = 1
recipe.ingredients = {{name="empire_food", amount=2}}
recipe.result_count = 1
data:extend{recipe}

recipe = table.deepcopy(data.raw["recipe"]["transport-belt"])
recipe.name = "empire_inserter"
recipe.localised_name = {"empire_inserter"}
recipe.result = "empire_inserter"
recipe.enabled = true
recipe.energy_required = 1
recipe.ingredients = {{name="empire_food", amount=2}}
recipe.result_count = 1
data:extend{recipe}

recipe = table.deepcopy(data.raw["recipe"]["iron-stick"])
recipe.name = "empire_spear"
recipe.localised_name = {"empire_spear"}
recipe.result = "empire_spear"
recipe.enabled = true
recipe.energy_required = 1
recipe.ingredients = {{name="empire_food", amount=2}}
recipe.result_count = 1
data:extend{recipe}

recipe = table.deepcopy(data.raw["recipe"]["light-armor"])
recipe.name = "empire_backpack"
recipe.localised_name = {"empire_backpack"}
recipe.result = "empire_backpack"
recipe.enabled = true
recipe.energy_required = 1
recipe.ingredients = {{name="empire_food", amount=2}}
recipe.result_count = 1
data:extend{recipe}

-- Handcrafting (placing blueprints)
recipe = table.deepcopy(data.raw["recipe"]["transport-belt"])
recipe.name = "empire_mechanical_belt_hand"
recipe.localised_name = {"empire_mechanical_belt"}
recipe.result = "empire_mechanical_belt"
recipe.enabled = true
recipe.energy_required = 0.002
recipe.ingredients = {}
recipe.result_count = 1
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire_storage_hand"
recipe.localised_name = {"empire_storage"}
recipe.result = "empire_storage"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire_inserter_hand"
recipe.localised_name = {"empire_inserter"}
recipe.result = "empire_inserter"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire_mining_drill_hand"
recipe.localised_name = {"empire_mining_drill"}
recipe.result = "empire_mining_drill"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire_furnace_hand"
recipe.localised_name = {"empire_furnace"}
recipe.result = "empire_furnace"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire_workshop_hand"
recipe.localised_name = {"empire_workshop"}
recipe.result = "empire_workshop"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire_greenhouse_hand"
recipe.localised_name = {"empire_greenhouse"}
recipe.result = "empire_greenhouse"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire_huntingcabin_hand"
recipe.localised_name = {"empire_huntingcabin"}
recipe.result = "empire_huntingcabin"
data:extend{recipe}

-- Remove vanilla recepies
for i, recipe in pairs(data.raw["recipe"]) do
	if not string.find(recipe.name, "empire-") then
		recipe.enabled = false
		if recipe.normal then
			recipe.normal.enabled = false
    end
		if recipe.expensive then
			recipe.expensive.enabled = false
    end
	end
end