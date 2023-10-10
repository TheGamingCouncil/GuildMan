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

-- Removes guild members offline for more than X days
function GM_NS.prune()
    GM_NS.CHAT:Print("Pruning inactive guild members...")
end

function GM_NS.listGuilds()
    GM_NS.CHAT:Print("Guild List")
    local numGuilds = GetNumGuilds()

    for guildIndex = 1, numGuilds do
        local guildName = GetGuildName(GetGuildId(guildIndex))
        GM_NS.CHAT:Print(guildIndex .. " - " .. guildName)
    end
end

-- Removes guild members offline for more than X days
function GM_NS.listInactiveGuildMembers()
    GM_NS.CHAT:Print("Listing inactive guild members...")

    local numMembers = GetNumGuildMembers(GM_NS.GUILD_TO_PRUNE)
    local numberOfInactiveMembers = 0
    local guildName = GetGuildName(GetGuildId(guildIndex))

    GM_NS.CHAT:Print("Processing " .. guildName)

    for memberIndex = 1, numMembers do
        local name, _, _, _, lastOnline = GetGuildMemberInfo(GM_NS.GUILD_TO_PRUNE, memberIndex)
        if (lastOnline > GM_NS.NUM_SECONDS_GUILD_MEMBER_CAN_BE_INACTIVE) then
            GM_NS.CHAT:Print("Inactive: " .. name .. ", online: " ..
                                         GM_NS.convertSecondsToDays(lastOnline) .. " days ago")
            numberOfInactiveMembers = numberOfInactiveMembers + 1
        end
    end
    GM_NS.CHAT:Print("Inactive members: " .. numberOfInactiveMembers)
end

function GM_NS.setGuild(guildNumber)
    GM_NS.CHAT:Print("Setting Guild to " .. GetGuildName(GetGuildId(guildNumber)))
    GM_NS.GUILD_TO_PRUNE = GetGuildId(guildNumber)
end

-- Global Slash Commands and SubCommands
GM_NS.SLASH_CMD = {{"/gm", "/guildman"}, GM_NS.printHelp, "print help info"}
GM_NS.SLASH_SUBCMDS = {{{"help", "h"}, GM_NS.printHelp, "print help info"},
                               {{"list-inactive", "li"}, GM_NS.listInactiveGuildMembers,"list inactive guildies"},
                               {{"list-guilds", "lg"}, GM_NS.listGuilds, "list guilds"},
                               {{"set-guild", "sg"}, GM_NS.setGuild, "set guild"},
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
    return math.floor(num / 24 / 60 / 60)
end

EVENT_MANAGER:RegisterForEvent(GM_NS.ADDON_NAME, EVENT_ADD_ON_LOADED, GM_NS.OnAddOnLoaded)
