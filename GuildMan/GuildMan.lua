--Define Namespace for Addon
GuildManAddon = {}
 
--Set name of addon
GuildManAddon.name = "GuildMan"

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

  --Register Subcommands
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
  --Finish Registering Subcommands
end

--Removes guild members offline for more than X days
function GuildManAddon.prune()
  GuildManAddon.G_CHAT:Print("Pruning inactive guild members...")
end

--Removes guild members offline for more than X days
function GuildManAddon.listInactive()
  GuildManAddon.G_CHAT:Print("Listing inactive guild members...")
end

--Prints the help info
function GuildManAddon.printHelp()
  GuildManAddon.G_CHAT:Print("valid commands: \n/gm \n/gm prune \n/gm list-inactive")
end
 
EVENT_MANAGER:RegisterForEvent(GuildManAddon.name, EVENT_ADD_ON_LOADED, GuildManAddon.OnAddOnLoaded)

