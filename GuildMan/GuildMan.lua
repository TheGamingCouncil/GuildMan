--Define Namespace for Addon
GuildManAddon = {}
 
--Set name of addon
GuildManAddon.name = "GuildMan"

--Global Strings
GuildManAddon.G_STRING_INITIALIZE_MSG="Loaded Addon: GuildMan"

--Global Libraries
GuildManAddon.G_LOGGER = LibDebugLogger(GuildManAddon.name)
GuildManAddon.G_CHAT = LibChatMessage(GuildManAddon.name, "GM")
GuildManAddon.G_LIB_SLASH_COMMANDER=LibSlashCommander

--Functions
function GuildManAddon.Initialize()
  GuildManAddon.G_LOGGER:Info(GuildManAddon.G_STRING_INITIALIZE_MSG)
  GuildManAddon.G_CHAT:Print(GuildManAddon.G_STRING_INITIALIZE_MSG)
  GuildManAddon.RegisterLibSlashCommanderCommands()
end
 
function GuildManAddon.OnAddOnLoaded(event, addonName)
  if addonName == GuildManAddon.name then
    GuildManAddon.Initialize()
    EVENT_MANAGER:UnregisterForEvent(GuildManAddon.name, EVENT_ADD_ON_LOADED)
  end
end

function GuildManAddon.RegisterLibSlashCommanderCommands()
  local command = GuildManAddon.G_LIB_SLASH_COMMANDER:Register()
  command:AddAlias("/guildman")
  command:AddAlias("/gm")
  command:SetCallback(function(input) d(input) GuildManAddon.G_CHAT:Print('It has worked') end)
  command:SetDescription("Guild Man: Prints help")
end
 
EVENT_MANAGER:RegisterForEvent(GuildManAddon.name, EVENT_ADD_ON_LOADED, GuildManAddon.OnAddOnLoaded)

