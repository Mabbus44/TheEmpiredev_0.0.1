-- Functions for hunting
function empire.huntStartMoving(squad)
	empireG.logF("huntStartMoving", {squad})
  squad.status = "moving"
  local dist = empire.dist(squad.position, squad.huntingPathTiles[squad.huntingPathGoal].p)
  local reachTick = dist/squad.moveSpeed*empireG.ticksPerSecond + game.tick
  empireG.addEvent(reachTick, empire.huntReachDestination, {squad})
end

function empire.huntReachDestination(squad)
	empireG.logF("huntReachDestination", {squad})
  squad.position = squad.huntingPathTiles[squad.huntingPathGoal].p
  if squad.huntingPathTiles.len == squad.huntingPathGoal then
    -- Reached home
    if empire.addItemTypeToStorage(empireG.surfaces[squad.home].surface, nil, "empire_food", squad.stock.empire_food) then
      squad.status = "unloading"
      squad.carriedWeight = squad.carriedWeight - squad.stock.empire_food * empireG.empire_food.weight
      squad.stock.empire_food = 0
      squad.huntingPathGoal = 1
      empire.huntStartHunting(squad)
    else
      empireG.addEvent(game.tick + empireG.ticksPerSecond * 10, empire.huntReachDestination, {squad})
    end
  else
    -- Reached a hunting location
    squad.status = "unpacking"
    local unpackedTick = squad.setupSpeed*empireG.ticksPerSecond + game.tick
    empireG.addEvent(unpackedTick, empire.huntStartHunting, {squad})
  end
end

function empire.huntStartHunting(squad)
	empireG.logF("huntStartHunting", {squad})
  squad.status = "hunting"
  local finishedHuntingTick = squad.huntingSpeed*empireG.ticksPerSecond + game.tick
  local p = squad.huntingPathTiles[squad.huntingPathGoal].p
  local wmTile = empireG.worldMapTiles[p.x .. "," .. p.y]
  if wmTile.currentTick ~= nil then
    local ticksToRegen = game.tick - wmTile.currentTick
    local foodToRegen = empireG.timeToGenerateFood*60*wmTile.maxFood / ticksToRegen
    wmTile.currentFood = math.min(wmTile.currentFood + foodToRegen, wmTile.maxFood)
  else
    wmTile.currentFood = wmTile.maxFood
  end
  wmTile.currentTick = game.tick
  local maxCarryFood = math.floor((squad.carryCapacity - squad.carriedWeight) / empireG.empire_food.weight)
  local foodToHunt = math.min(wmTile.currentFood, maxCarryFood)
  local finishedHuntingTick = foodToHunt / squad.huntingSpeed * empireG.ticksPerSecond + game.tick
  empireG.addEvent(finishedHuntingTick, empire.huntFinishHunting, {squad, foodToHunt})
end

function empire.huntFinishHunting(squad, foodToAdd)
	empireG.logF("huntFinishHunting", {squad, foodToAdd})
  squad.status = "packing"
  local p = squad.huntingPathTiles[squad.huntingPathGoal].p
  local wmTile = empireG.worldMapTiles[p.x .. "," .. p.y]
  squad.stock.empire_food = squad.stock.empire_food + foodToAdd
  wmTile.currentFood = wmTile.currentFood - foodToAdd
  wmTile.currentTick = game.tick
  squad.carriedWeight = squad.carriedWeight + foodToAdd * empireG.empire_food.weight
  local packedTick = squad.setupSpeed*empireG.ticksPerSecond + game.tick
  squad.huntingPathGoal = squad.huntingPathGoal + 1
  empireG.addEvent(packedTick, empire.huntStartMoving, {squad})
end