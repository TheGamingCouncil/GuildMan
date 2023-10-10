GM_NS = {}; -- GuildMan Namespace

-- Global Vars
GM_NS.ADDON_NAME = "GuildMan"; -- addon name
GM_NS.MAX_SECONDS_MEMBER_INACTIVE = 604800; -- default is 7 days in seconds
GM_NS.ACTIVE_GUILD = ""; -- guild to work on
GM_NS.INITIALIZE_MESSAGE = "Loaded Addon: " .. GM_NS.ADDON_NAME; -- message printed on startup
GM_NS.GOODBYE_EMAIL_SUBJECT = "Goodbye %s from %s!"
GM_NS.GOODBYE_EMAIL_BODY =
    "Hello %s,\nYou've been removed from %s for being inactive for more than %d days.\nThanks,\nThe Gaming Council"
GM_NS.WHITELIST = {GetDisplayName()}; -- people to never kick from guilds

-- Global Libraries
GM_NS.LOGGER = LibDebugLogger(GM_NS.ADDON_NAME); -- Debug logging
GM_NS.CHAT = LibChatMessage(GM_NS.ADDON_NAME, "GM"); -- Output to chat
GM_NS.LIB_SLASH_CMDR = LibSlashCommander; -- CLI Library

-- Functions

--- Prints the help info
function GM_NS.printHelp()  
  local strHelp = "Help:\nType: /gm <command>\n<command> can be:\n"
  for _, sub_cmd in ipairs(GM_NS.SLASH_SUBCMDS) do
    local subCmdText = string.format("%s (%s) - %s \n",sub_cmd[1][1],sub_cmd[1][2],sub_cmd[3])
    strHelp = strHelp + subCmdText
  end
  GM_NS.CHAT:Print(strHelp)
end

--- send mail
function GM_NS.sendLeavingMail(guildId, name)

    local guildName = GetGuildName(guildId)
    local days = GM_NS.SecondsToDays(GM_NS.MAX_SECONDS_MEMBER_INACTIVE);
    local subject = string.format(GM_NS.GOODBYE_EMAIL_SUBJECT, name, guildName)
    local body = string.format(GM_NS.GOODBYE_EMAIL_BODY, name, guildName, days)

    GM_NS.CHAT:Print("Sending farewell mail")
    SendMail(name, subject, body)
end

--- Kick from guild
function GM_NS.kickFromGuild(guildId, name)
    GM_NS.CHAT:Print("Kicking " .. name)
    GuildRemove(guildId, name)
end

--- Removes guild members offline for more than X days
function GM_NS.pruneInactiveMembers()
    GM_NS.operateOnInactiveMembers(true)
end

--- List guild members offline for more than X days
function GM_NS.listInactiveMembers()
    GM_NS.operateOnInactiveMembers(false)
end

--- Operate on inactive members
function GM_NS.operateOnInactiveMembers(kickMode)
    local guildId = GM_NS.ACTIVE_GUILD
    local numberOfInactiveMembers = 0
    local numberOfTotalMembers = GetNumGuildMembers(guildId)
    local guildName = GetGuildName(guildId)
    local strMethodInfo = string.format("Guild: %s\nkick mode: %s\ntotal guild members: %d", guildName, tostring(kickMode),  numberOfTotalMembers)

    GM_NS.CHAT:Print(strMethodInfo)

    for memberIndex = 1, numberOfTotalMembers do
        local name, _, _, _, lastOnline = GetGuildMemberInfo(guildId, memberIndex)

        -- set to < for testing, usually >.
        if (tonumber(lastOnline) > tonumber(GM_NS.MAX_SECONDS_MEMBER_INACTIVE)) then
            local inactiveInDays = GM_NS.SecondsToDays(lastOnline)

            local strInactiveMember = string.format("Inactive: %s, online: %d days ago", name, inactiveInDays)
            GM_NS.CHAT:Print(strInactiveMember)
            numberOfInactiveMembers = numberOfInactiveMembers + 1

            if (kickMode and GM_NS.checkWhitelist(name)) then
                GM_NS.kickFromGuild(guildId, name)
                GM_NS.sendLeavingMail(guildId, name)
            end
        end
    end
    GM_NS.CHAT:Print("Inactive members: " .. numberOfInactiveMembers)
end

--- list guilds user is in
function GM_NS.listGuilds()
    GM_NS.CHAT:Print("Guild List")
    local numGuilds = GetNumGuilds()

    for guildIndex = 1, numGuilds do
        local guildName = GetGuildName(GetGuildId(guildIndex))
        GM_NS.CHAT:Print(guildIndex .. " - " .. guildName)
    end
end

--- set active guild
function GM_NS.setGuild(guildNumber)
    local guildID = GetGuildId(guildNumber)
    GM_NS.CHAT:Print("Setting Guild to " .. GetGuildName(guildID))
    GM_NS.ACTIVE_GUILD = guildID
end

--- set inactive time
function GM_NS.setInactiveTime(inactiveTime)
    local strSetInactiveTime = string.format("Setting MAX_SECONDS_MEMBER_INACTIVE to %d ( %d days)", inactiveTime,
        GM_NS.SecondsToDays(inactiveTime))
    GM_NS.CHAT:Print(strSetInactiveTime)
    GM_NS.MAX_SECONDS_MEMBER_INACTIVE = inactiveTime
end

--- get inactive time
function GM_NS.getInactiveTime()
    local inactive_in_secs = GM_NS.MAX_SECONDS_MEMBER_INACTIVE
    local inactive_in_days = GM_NS.SecondsToDays(GM_NS.MAX_SECONDS_MEMBER_INACTIVE)
    local strGetInactiveTime = string.format("MAX_SECONDS_MEMBER_INACTIVE is %d ( %d days)", inactive_in_secs,
        inactive_in_days)
    GM_NS.CHAT:Print(strGetInactiveTime)
end

--- Check whitelist for name
function GM_NS.checkWhitelist(name)
    for key, value in pairs(GM_NS.WHITELIST) do

        if (name == value) then
            -- In whitelist
            return false
        end
    end

    -- Not in whitelist
    return true
end

--- Convert seconds to days (rounded)
function GM_NS.SecondsToDays(seconds)
    return math.floor(tonumber(seconds) / 24 / 60 / 60)
end

-- Global Slash Commands and SubCommands
GM_NS.SLASH_CMD = {{"/gm", "/guildman"}, GM_NS.printHelp, "print help info"}
GM_NS.SLASH_SUBCMDS = {{{"help", "h"}, GM_NS.printHelp, "print help info"},
                       {{"list-inactive", "li"}, GM_NS.listInactiveMembers, "list inactive guild members"},
                       {{"list-guilds", "lg"}, GM_NS.listGuilds, "list guilds"},
                       {{"set-guild", "sg"}, GM_NS.setGuild, "set guild <num>"},
                       {{"set-inactive-time", "si"}, GM_NS.setInactiveTime, "set inactive time in seconds"},
                       {{"get-inactive-time", "gi"}, GM_NS.getInactiveTime, "get inactive time in seconds"},
                       {{"prune", "p"}, GM_NS.pruneInactiveMembers, "prune guild members"}}

--- register commands with slash commander addon
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

--- Initialize addon
function GM_NS.Initialize()
    GM_NS.LOGGER:Info(GM_NS.INITIALIZE_MESSAGE)
    GM_NS.CHAT:Print(GM_NS.INITIALIZE_MESSAGE)
    GM_NS.RegisterSlashCommands()
end

--- Startup
function GM_NS.OnAddOnLoaded(event, addonName)
    if addonName == GM_NS.ADDON_NAME then
        GM_NS.Initialize()
        EVENT_MANAGER:UnregisterForEvent(GM_NS.ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(GM_NS.ADDON_NAME, EVENT_ADD_ON_LOADED, GM_NS.OnAddOnLoaded)
