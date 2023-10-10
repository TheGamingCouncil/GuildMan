GM_NS = {}; --GuildMan Namespace

-- Global Vars
GM_NS.ADDON_NAME = "GuildMan";
GM_NS.NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE = 604800;
GM_NS.GUILD_TO_PRUNE = ""; --guild to purge of inactivity

-- Global Messages 
GM_NS.INITIALIZE_MESSAGE = "Loaded Addon: " .. GM_NS.ADDON_NAME

-- Global Libraries
GM_NS.LOGGER = LibDebugLogger(GM_NS.ADDON_NAME); -- Debug logging
GM_NS.CHAT = LibChatMessage(GM_NS.ADDON_NAME, "GM"); -- Output to chat
GM_NS.LIB_SLASH_CMDR = LibSlashCommander; -- CLI Library

-- Functions

-- Prints the help info
function GM_NS.printHelp()
    GM_NS.CHAT:Print("Help:")
    GM_NS.CHAT:Print("Type: /gm <command>")
    GM_NS.CHAT:Print("<command> can be:")

    for _, sub_cmd in ipairs(GM_NS.SLASH_SUBCMDS) do
        GM_NS.CHAT:Print(" " .. sub_cmd[1][1] .. " (" .. sub_cmd[1][2] .. ")" .. " - " .. sub_cmd[3])
    end
end

--mail aux Function
function GM_NS.sendLeavingMail(guildId, name)
  

  local guildName = GetGuildName(GetGuildId(guildIndex))
  local subject = "Goodbye " .. name .. " from " .. guildName .. "!"
  local body = "Hello " .. name .. ",\n"
  .. "You've been removed from" .. guildName .. "for being inactive for more than "
  .. GM_NS.convertSecondsToDays(GM_NS.NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE)
  .. " days.\n"
  .. "Thanks,\n"
  .. "The Gaming Council"

  if(name == "@RizzleMaTizzle") then return end

  GM_NS.CHAT:Print("Sending farewell mail")
  SendMail(name,subject,body)
end

--kick from guild
function GM_NS.kickFromGuild(guildId,name)
  if(name == "@RizzleMaTizzle") then return end

  GM_NS.CHAT:Print("Kicking " .. name)
  GuildRemove(guildId,name)
end

-- Removes guild members offline for more than X days
function GM_NS.prune()
  GM_NS.operateOnInactiveGuildMembers(true)
end

-- Removes guild members offline for more than X days
function GM_NS.listInactiveGuildMembers()
  GM_NS.operateOnInactiveGuildMembers(false)
end

function GM_NS.operateOnInactiveGuildMembers(kickMode)
  local guildId = GM_NS.GUILD_TO_PRUNE
  local numberOfInactiveMembers = 0
  local numberOfTotalMembers = GetNumGuildMembers(guildId)
  local guildName = GetGuildName(guildId)

  GM_NS.CHAT:Print("kickMode is ".. tostring(kickMode))
  GM_NS.CHAT:Print("Listing inactive guild members in " .. guildName)
  GM_NS.CHAT:Print("Total guild members in " .. numberOfTotalMembers)

  for memberIndex = 1, numberOfTotalMembers do
      local name, _, _, _, lastOnline = GetGuildMemberInfo(guildId, memberIndex)
      
      --set to < for testing, usually >.
      if (tonumber(lastOnline) > tonumber(GM_NS.NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE)) then
          GM_NS.CHAT:Print("Inactive: " .. name .. ", online: " ..
                                       GM_NS.convertSecondsToDays(lastOnline) .. " days ago")
          numberOfInactiveMembers = numberOfInactiveMembers + 1

          if(kickMode) then
            GM_NS.kickFromGuild(guildId, name)
            GM_NS.sendLeavingMail(guildId, name)
          end
      end
  end
  GM_NS.CHAT:Print("Inactive members: " .. numberOfInactiveMembers)
end

function GM_NS.listGuilds()
  GM_NS.CHAT:Print("Guild List")
  local numGuilds = GetNumGuilds()

  for guildIndex = 1, numGuilds do
      local guildName = GetGuildName(GetGuildId(guildIndex))
      GM_NS.CHAT:Print(guildIndex .. " - " .. guildName)
  end
end

function GM_NS.setGuild(guildNumber)
    local guildID=GetGuildId(guildNumber)
    GM_NS.CHAT:Print("Setting Guild to " .. GetGuildName(guildID))
    GM_NS.GUILD_TO_PRUNE = guildID
end

function GM_NS.setInactiveTime(inactiveTime)
  GM_NS.CHAT:Print("Setting NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE to " .. inactiveTime .. " (" .. GM_NS.convertSecondsToDays(inactiveTime) .. " days)")
  GM_NS.NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE = inactiveTime
end

function GM_NS.getInactiveTime()
  GM_NS.CHAT:Print("Inactive Time is " .. GM_NS.NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE .. " (" .. GM_NS.convertSecondsToDays(GM_NS.NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE) .. " days)")
end

-- Global Slash Commands and SubCommands
GM_NS.SLASH_CMD = {{"/gm", "/guildman"}, GM_NS.printHelp, "print help info"}
GM_NS.SLASH_SUBCMDS = {{{"help", "h"}, GM_NS.printHelp, "print help info"},
                               {{"list-inactive", "li"}, GM_NS.listInactiveGuildMembers,"list inactive guildies"},
                               {{"list-guilds", "lg"}, GM_NS.listGuilds, "list guilds"},
                               {{"set-guild", "sg"}, GM_NS.setGuild, "set guild"},
                               {{"set-inactive-time", "si"}, GM_NS.setInactiveTime, "set inactive time in seconds"},
                               {{"get-inactive-time", "gi"}, GM_NS.getInactiveTime, "get inactive time in seconds"},
                               {{"prune", "p"}, GM_NS.prune, "prune guild members"}}

function GM_NS.RegisterSlashCommands()
    -- Register Slash Command
    local command = GM_NS.LIB_SLASH_CMDR:Register()
    command:AddAlias(GM_NS.SLASH_CMD[1][1])
    command:AddAlias(GM_NS.SLASH_CMD[1][2])
    command:SetCallback(GM_NS.SLASH_CMD[2])
    command:SetDescription(GM_NS.SLASH_CMD[3])

    -- Register Slash Subcommands
    for _, sub_cmd in ipairs(GM_NS.SLASH_SUBCMDS) do
        local subcommand = command:RegisterSubCommand()
        subcommand:AddAlias(sub_cmd[1][1])
        subcommand:AddAlias(sub_cmd[1][2])
        subcommand:SetCallback(sub_cmd[2])
        subcommand:SetDescription(sub_cmd[3])
    end
end

function GM_NS.Initialize()
    GM_NS.LOGGER:Info(GM_NS.INITIALIZE_MESSAGE)
    GM_NS.CHAT:Print(GM_NS.INITIALIZE_MESSAGE)
    GM_NS.RegisterSlashCommands()
end

function GM_NS.OnAddOnLoaded(event, addonName)
    if addonName == GM_NS.ADDON_NAME then
        GM_NS.Initialize()
        EVENT_MANAGER:UnregisterForEvent(GM_NS.ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

function GM_NS.convertSecondsToDays(num)
    return math.floor(tonumber(num) / 24 / 60 / 60)
end

EVENT_MANAGER:RegisterForEvent(GM_NS.ADDON_NAME, EVENT_ADD_ON_LOADED, GM_NS.OnAddOnLoaded)
