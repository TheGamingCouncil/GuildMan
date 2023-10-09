--Define Namespace for Addon
GuildManAddon = {}
 
--Set name of addon
GuildManAddon.name = "GuildMan"

--Global Vars
GuildManAddon.G_NUM_SECONDS_INACTIVE=604800
--Global Messages 
GuildManAddon.G_STRING_INITIALIZE_MSG="Loaded Addon: GuildMan"

--Global Slash Commands
GuildManAddon.G_STRING_SLASH_CMD_DESC_GUILDMAN="GuildMan - Prints Help"
GuildManAddon.G_ARRAY_SLASH_CMD_ALIASES_GUILDMAN={"/gm", "/guildman"}

--Global Slash SubCommands
GuildManAddon.G_ARRAY_SLASH_SUBCMD_GUILDMAN_PRUNE_ALIAS={"prune","p"}
GuildManAddon.G_STRING_SLASH_SUBCMD_GUILDMAN_PRUNE_DESC="prune guild members"

GuildManAddon.G_ARRAY_SLASH_SUBCMD_GUILDMAN_HELP_ALIAS={"help","h"}
GuildManAddon.G_STRING_SLASH_SUBCMD_GUILDMAN_HELP_DESC="print help"

GuildManAddon.G_ARRAY_SLASH_SUBCMD_GUILDMAN_LIST_INACTIVE_ALIAS={"list-inactive","li"}
GuildManAddon.G_STRING_SLASH_SUBCMD_GUILDMAN_LIST_INACTIVE_DESC="list inactive guild members"

GuildManAddon.G_ARRAY_SLASH_SUBCMD_GUILDMAN_LIST_GUILDS_ALIAS={"list-guilds","lg"}
GuildManAddon.G_STRING_SLASH_SUBCMD_GUILDMAN_LIST_GUILDS_DESC="list guilds"


--Global Libraries
GuildManAddon.G_LOGGER = LibDebugLogger(GuildManAddon.name)
GuildManAddon.G_CHAT = LibChatMessage(GuildManAddon.name, "GM")
GuildManAddon.G_LIB_SLASH_COMMANDER=LibSlashCommander

--Functions
function GuildManAddon.Initialize()
  GuildManAddon.G_LOGGER:Info(GuildManAddon.G_STRING_INITIALIZE_MSG)
  GuildManAddon.G_CHAT:Print(GuildManAddon.G_STRING_INITIALIZE_MSG)
  GuildManAddon.RegisterSlashCommands()
end
 
function GuildManAddon.OnAddOnLoaded(event, addonName)
  if addonName == GuildManAddon.name then
    GuildManAddon.Initialize()
    EVENT_MANAGER:UnregisterForEvent(GuildManAddon.name, EVENT_ADD_ON_LOADED)
  end
end

--Generic method to register a slash command with Lib_Slash_Commander 
function GuildManAddon.RegisterSlashCommand(command, aliases, funcToCall, description)
  
  --register the command aliases
  for _, alias in ipairs(aliases) do
    command:AddAlias(alias)
  end

  --register the function
  command:SetCallback(funcToCall)

  --set the description
  command:SetDescription(description)
end

function GuildManAddon.RegisterSlashSubCommand(command, aliases, funcToCall, description)
  local subcommand = command:RegisterSubCommand()
  --register the command aliases
  for _, alias in ipairs(aliases) do
    subcommand:AddAlias(alias)
  end

  --register the function
  subcommand:SetCallback(funcToCall)

  --set the description
  subcommand:SetDescription(description)
end

function GuildManAddon.RegisterSlashCommands()
 
  local command = GuildManAddon.G_LIB_SLASH_COMMANDER:Register()

  --Register /gm slash command
  GuildManAddon.RegisterSlashCommand(
    command,
    GuildManAddon.G_ARRAY_SLASH_CMD_ALIASES_GUILDMAN,
    GuildManAddon.printHelp,
    GuildManAddon.G_STRING_SLASH_CMD_DESC_GUILDMAN
  )
  --Finish registering /gm slash command

  --Register Subcommands of /gm
  GuildManAddon.RegisterSlashSubCommand(
    command,
    GuildManAddon.G_ARRAY_SLASH_SUBCMD_GUILDMAN_PRUNE_ALIAS,
    GuildManAddon.prune,
    GuildManAddon.G_STRING_SLASH_SUBCMD_GUILDMAN_PRUNE_DESC
  )

  GuildManAddon.RegisterSlashSubCommand(
    command,
    GuildManAddon.G_ARRAY_SLASH_SUBCMD_GUILDMAN_HELP_ALIAS,
    GuildManAddon.printHelp,
    GuildManAddon.G_STRING_SLASH_SUBCMD_GUILDMAN_HELP_DESC
  )

  GuildManAddon.RegisterSlashSubCommand(
    command,
    GuildManAddon.G_ARRAY_SLASH_SUBCMD_GUILDMAN_LIST_INACTIVE_ALIAS,
    GuildManAddon.listInactive,
    GuildManAddon.G_STRING_SLASH_SUBCMD_GUILDMAN_LIST_INACTIVE_DESC
  )

  GuildManAddon.RegisterSlashSubCommand(
    command,
    GuildManAddon.G_ARRAY_SLASH_SUBCMD_GUILDMAN_LIST_GUILDS_ALIAS,
    GuildManAddon.listGuilds,
    GuildManAddon.G_STRING_SLASH_SUBCMD_GUILDMAN_LIST_GUILDS_DESC
  )
  --Finish Registering Subcommands
end

--Removes guild members offline for more than X days
function GuildManAddon.prune()
  GuildManAddon.G_CHAT:Print("Pruning inactive guild members...")
end

--Removes guild members offline for more than X days
function GuildManAddon.listInactive()
  GuildManAddon.G_CHAT:Print("Listing inactive guild members...")
  local numberOfGuilds = GetNumGuilds()

  for guildIndex = 1, numberOfGuilds do
    local guildName =  GetGuildName(GetGuildId(guildIndex))
    local numMembers = GetNumGuildMembers(GetGuildId(guildIndex))
    local numberOfInactiveMembers = 0
    GuildManAddon.G_CHAT:Print("Processing " .. guildName )

    for memberIndex = 1, numMembers do
      local name, _, _, _, lastOnline = GetGuildMemberInfo(GetGuildId(guildIndex), memberIndex)
      if(lastOnline > GuildManAddon.G_NUM_SECONDS_INACTIVE) then
        GuildManAddon.G_CHAT:Print("Inactive: " .. name .. ", online: " .. GuildManAddon.convertSecondsToDays(lastOnline) .. " days ago")
        numberOfInactiveMembers = numberOfInactiveMembers + 1
      end
    end
    GuildManAddon.G_CHAT:Print("Inactive members: " .. numberOfInactiveMembers)
  end
  GuildManAddon.G_CHAT:Print("All Guilds Processed")
end

function GuildManAddon.listGuilds()
  GuildManAddon.G_CHAT:Print("Guild List")
  local numGuilds = GetNumGuilds()

  for i = 1, numGuilds do
    local guildName = GetGuildName(GetGuildId(i))
    GuildManAddon.G_CHAT:Print(i .. " - " .. guildName)
  end
end

function GuildManAddon.setGuild()
  GuildManAddon.G_CHAT:Print("Setting Guild")
  
end

--Prints the help info
function GuildManAddon.printHelp()
  GuildManAddon.G_CHAT:Print("valid commands: \n/gm \n/gm prune \n/gm list-inactive")
end

function GuildManAddon.convertSecondsToDays(num)
  return math.floor(num / 24 / 60 / 60)
end


 
EVENT_MANAGER:RegisterForEvent(GuildManAddon.name, EVENT_ADD_ON_LOADED, GuildManAddon.OnAddOnLoaded)

