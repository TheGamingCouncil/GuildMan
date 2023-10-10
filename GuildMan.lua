  --Define Namespace for Addon
  GuildManAddon = {}

  --Global Vars
  GuildManAddon.NAME = "GuildMan"
  GuildManAddon.NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE = 604800
  GuildManAddon.GUILD_TO_PRUNE = ""

  --Global Messages 
  GuildManAddon.INITIALIZE_MESSAGE = "Loaded Addon: GuildMan"

  --Global Libraries
  GuildManAddon.LOGGER = LibDebugLogger(GuildManAddon.NAME); --Debug logging
  GuildManAddon.CHAT = LibChatMessage(GuildManAddon.NAME, "GM"); --Output to chat
  GuildManAddon.LIB_SLASH_CMDR = LibSlashCommander; --CLI Library

  --Functions

  --Prints the help info
  function GuildManAddon.printHelp()
    GuildManAddon.CHAT:Print("Help:")
    GuildManAddon.CHAT:Print("Type: /gm <command>")
    GuildManAddon.CHAT:Print("<command> can be:")

    for _, sub_cmd in ipairs(GuildManAddon.SLASH_SUBCMDS) do
      GuildManAddon.CHAT:Print(" " .. sub_cmd[1][1] .. " (" .. sub_cmd[1][2] .. ")" .. " - " .. sub_cmd[3])
    end
    
    for _, sub_cmd in ipairs(GuildManAddon.SLASH_SUBCMDS) do
      local s_aliases, s_func, s_desc = table.unpack(sub_cmd)
    end
  end
  --Removes guild members offline for more than X days
  function GuildManAddon.prune()
    GuildManAddon.CHAT:Print("Pruning inactive guild members...")
  end

  function GuildManAddon.listGuilds()
    GuildManAddon.CHAT:Print("Guild List")
    local numGuilds = GetNumGuilds()

    for guildIndex = 1, numGuilds do
      local guildName = GetGuildName(GetGuildId(guildIndex))
      GuildManAddon.CHAT:Print(guildIndex .. " - " .. guildName)
    end
  end

  --Removes guild members offline for more than X days
  function GuildManAddon.listInactiveGuildMembers()
    GuildManAddon.CHAT:Print("Listing inactive guild members...")
 
      local numMembers = GetNumGuildMembers(GuildManAddon.GUILD_TO_PRUNE)
      local numberOfInactiveMembers = 0
      local guildName = GetGuildName(GetGuildId(guildIndex))

      GuildManAddon.CHAT:Print("Processing " .. guildName )

      for memberIndex = 1, numMembers do
        local name, _, _, _, lastOnline = GetGuildMemberInfo(GuildManAddon.GUILD_TO_PRUNE, memberIndex)
        if(lastOnline > GuildManAddon.NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE) then
          GuildManAddon.CHAT:Print("Inactive: " .. name .. ", online: " .. GuildManAddon.convertSecondsToDays(lastOnline) .. " days ago")
          numberOfInactiveMembers = numberOfInactiveMembers + 1
        end
      end
      GuildManAddon.CHAT:Print("Inactive members: " .. numberOfInactiveMembers)
  end

  function GuildManAddon.setGuild(guildNumber)
    GuildManAddon.CHAT:Print("Setting Guild to " .. GetGuildName(GetGuildId(guildNumber)))
    GuildManAddon.GUILD_TO_PRUNE = GetGuildId(guildNumber)
  end

  --Global Slash Commands and SubCommands
  GuildManAddon.SLASH_CMD={{"/gm", "/guildman"}, GuildManAddon.printHelp, "print help info"}
  GuildManAddon.SLASH_SUBCMDS={
    {{"help","h"}, GuildManAddon.printHelp, "print help info"},
    {{"list-inactive","li"}, GuildManAddon.listInactiveGuildMembers, "list inactive guildies"},
    {{"list-guilds","lg"}, GuildManAddon.listGuilds, "list guilds"},
    {{"set-guild","sg"}, GuildManAddon.setGuild, "set guild"},
    {{"prune","p"}, GuildManAddon.prune, "prune guild members"}
  }

  function GuildManAddon.RegisterSlashCommands()
    --Register Slash Command
    local command = GuildManAddon.LIB_SLASH_CMDR:Register()
    command:AddAlias(GuildManAddon.SLASH_CMD[1][1])
    command:AddAlias(GuildManAddon.SLASH_CMD[1][2])
    command:SetCallback(GuildManAddon.SLASH_CMD[2])
    command:SetDescription(GuildManAddon.SLASH_CMD[3])

    -- Register Slash Subcommands
    for _, sub_cmd in ipairs(GuildManAddon.SLASH_SUBCMDS) do
      local subcommand = command:RegisterSubCommand()
      subcommand:AddAlias(sub_cmd[1][1])
      subcommand:AddAlias(sub_cmd[1][2])
      subcommand:SetCallback(sub_cmd[2])
      subcommand:SetDescription(sub_cmd[3])
    end
  end

  function GuildManAddon.Initialize()
    GuildManAddon.LOGGER:Info(GuildManAddon.INITIALIZE_MESSAGE)
    GuildManAddon.CHAT:Print(GuildManAddon.INITIALIZE_MESSAGE)
    GuildManAddon.RegisterSlashCommands()
  end
  
  function GuildManAddon.OnAddOnLoaded(event, addonName)
    if addonName == GuildManAddon.NAME then
      GuildManAddon.Initialize()
      EVENT_MANAGER:UnregisterForEvent(GuildManAddon.NAME, EVENT_ADD_ON_LOADED)
    end
  end

  function GuildManAddon.convertSecondsToDays(num)
    return math.floor(num / 24 / 60 / 60)
  end

  EVENT_MANAGER:RegisterForEvent(GuildManAddon.NAME, EVENT_ADD_ON_LOADED, GuildManAddon.OnAddOnLoaded)