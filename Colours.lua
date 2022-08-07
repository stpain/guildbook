

local name, addon = ...;

addon.Colours = {}

for k, v in pairs(RAID_CLASS_COLORS) do
    addon.Colours[k] = CreateColor(v:GetRGB())
end

addon.Colours.Slate = CreateColor(121/256, 152/256, 174/256);
addon.Colours.DarkSlateGreen = CreateColor(42/256, 60/256, 59/256);
addon.Colours.DarkSlateGrey = CreateColor(101/256, 113/256, 113/256);
addon.Colours.DarkGold = CreateColor(204/256, 136/256, 0/256);
addon.Colours.Brown = CreateColor(36/256, 24/256, 0/256);
addon.Colours.MediumBrown = CreateColor(66/256, 44/256, 10/256);
addon.Colours.Guild = CreateColor(60/256, 225/256, 63/256);
addon.Colours.Grey = CreateColor(0.5, 0.5, 0.5);