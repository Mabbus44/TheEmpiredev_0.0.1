local empire = {}
local includes = {
	"control/gui/top.lua",
	"control/gui/status.lua",
	"control/gui/vault.lua",
	"control/gui/storage.lua",
	"control/gui/workshop.lua"}
for i, lib in pairs(includes) do
	local newFunctions = require(lib) 
	for k,v in pairs(newFunctions) do empire[k] = v end
end

function empire.isGuiParent(element, parentName)
	local parent = element
	while parent ~= nil do
		if parent.name == parentName then return true end
		parent = parent.parent
	end
	return false
end

function empire.handleOpenGui(player, entity)
	if entity == nil then return end
	if entity.name == "empire-world-map-tile" and empireG.worldMapTiles["" .. entity.position.x .. "," .. entity.position.y] ~= nil then 
		player.opened = nil
		player.teleport({x=0, y=0}, empireG.worldMapTiles["" .. entity.position.x .. "," .. entity.position.y].surface)
	elseif entity.name == "empire_vault" then
		player.opened = nil
		empire.openVaultGui(player, entity)
	elseif entity.name == "empire_storage" then
		empire.openStorageGui(player, entity)
	elseif entity.name == "empire_workshop" then
		empire.openWorkshopGui(player, entity)
	end
end

function empire.handleCloseGui(player, entity, element, guiType)
	if empire.isGuiParent(element, "vaultGui") then empire.closeVaultGui(player) end
	if guiType == defines.gui_type.entity and entity.name == "empire_storage" then empire.closeStorageGui(player) end
	if guiType == defines.gui_type.entity and entity.name == "empire_workshop" then empire.closeWorkshopGui(player) end
end

function empire.handleGuiButtons(player, element)
	if element.name == "closeVaultGui" then
		empire.closeVaultGui(player)
	elseif element.name == "closeStorageItemsGui" then
		empire.closeStorageItemsGui(player)
	elseif element.name == "closeWorkshopItemsGui" then
		empire.closeWorkshopItemsGui(player)
	elseif element.name == "goToWorldMap" then
		player.teleport({x=0, y=0}, game.surfaces["nauvis"])
	elseif element.name == "showFood" then
		empire.showFood({math.floor(player.position.x), math.floor(player.position.y)})
	elseif empire.isGuiParent(element, "storageFilterGui") then empire.handleStorageButtonPress(player, element)
	elseif empire.isGuiParent(element, "storageItemsGui") then empire.handleStorageItemsButtonPress(player, element)
	elseif empire.isGuiParent(element, "workshopProgressGui") then empire.handleWorkshopButtonPress(player, element)
	elseif empire.isGuiParent(element, "workshopItemsGui") then empire.handleWorkshopItemsButtonPress(player, element)
	end
end

function empire.showFood(position)
	log("showFood " .. game.tick)
	for y=position[2]-20,position[2]+20 do
		for x=position[1]-20,position[1]+20 do
			if empireG.worldMapTiles[x .. "," .. y] ~= nil then
				empire.showText({x,y}, empireG.worldMapTiles[x .. "," .. y].maxFood)
			end
		end
	end
	empireG.addEvent(game.tick+600,empire.clearText,{})
end

function empire.showText(position, value)
	--log("showText " .. game.tick)
	if value == nil then return end
	rendering.draw_text{text=tostring(value),surface=game.surfaces["nauvis"],target={position[1]+0.5,position[2]+0.3},color={1,1,1},alignment="center",vertical_alignment="middle"}
	rendering.draw_text{text="",surface=game.surfaces["nauvis"],target={position[1]+0.5,position[2]+0.7},color={1,1,1},alignment="center",vertical_alignment="middle"}
end

function empire.clearText()
	log("clearText " .. game.tick)
	rendering.clear()
end

return empire