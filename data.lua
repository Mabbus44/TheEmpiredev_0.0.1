require("data/entities.lua")
require("data/recipes.lua")
require("data/items.lua")
require("data/technologies.lua")

local sprite = table.deepcopy(data.raw["sprite"]["developer"])
sprite.name = "empire-general"
data:extend{sprite}

sprite = table.deepcopy(data.raw["sprite"]["developer"])
sprite.name = "empire-add"
sprite.filename = "__core__/graphics/bonus-icon.png"
sprite.width = 32
sprite.height = 32

data:extend{sprite}
