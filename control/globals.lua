local empireG = {}

empireG.worldMapTiles = {}							-- Key is coordinates, so "1,4", "-1,-19"...
empireG.surfaces = {}										-- Key is surface name, so "settlement1", "settlement2"...
empireG.settlementCount = 0							-- Keep track of settlement count
empireG.entityStats = {}								-- Key is "unit_number" of enties that has extra custom stats
empireG.runFunctionOnTick = {0, 0, 0}		-- One tickcounter per function

return empireG
