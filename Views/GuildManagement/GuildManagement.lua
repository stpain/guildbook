

local addonName, addon = ...;


GuildbookGuildManagementMixin = {
    name = "GuildManagement"
}

function GuildbookGuildManagementMixin:OnLoad()
    

    addon.AddView(self)
end