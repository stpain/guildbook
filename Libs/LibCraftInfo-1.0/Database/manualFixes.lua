--[[ 
Use this file if you want to correct an auto-generated value in one of the other data files.
Entries are usually stored into a single number, simply for faster loading.

If a spell must be modified, do it like this:

local lib = LibStub("LibCraftInfo-1.0")
local professionId = lib:GetProfessionInternalID("First Aid")

lib:SetCraftInfo(professionId, spellID, xpack, itemID, recipeID)

ex:
lib:SetCraftInfo(10, 3275, 1, 1251)

This means: 

- profession id 10 (first aid)
- spell id 3275
- expansion level is 1 (1 = wow vanilla, 2 = bc, etc..)
- created itemID 1251

if the spell is learned by a recipe item, use the 5th parameter to pass the recipe's itemID.

--]]