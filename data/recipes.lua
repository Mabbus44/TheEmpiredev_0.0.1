-- New recipes
local recipe = table.deepcopy(data.raw["recipe"]["transport-belt"])
recipe.name = "empire-mechanical-belt"
recipe.localised_name = {"empire-mechanical-belt"}
recipe.result = "empire-mechanical-belt"
recipe.enabled = true
recipe.energy_required = 0.002
recipe.ingredients = {}
recipe.result_count = 1
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire-storage"
recipe.localised_name = {"empire-storage"}
recipe.result = "empire-storage"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire-inserter"
recipe.localised_name = {"empire-inserter"}
recipe.result = "empire-inserter"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire-mining-drill"
recipe.localised_name = {"empire-mining-drill"}
recipe.result = "empire-mining-drill"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire-furnace"
recipe.localised_name = {"empire-furnace"}
recipe.result = "empire-furnace"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire-workshop"
recipe.localised_name = {"empire-workshop"}
recipe.result = "empire-workshop"
data:extend{recipe}

recipe = table.deepcopy(recipe)
recipe.name = "empire-greenhouse"
recipe.localised_name = {"empire-greenhouse"}
recipe.result = "empire-greenhouse"
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