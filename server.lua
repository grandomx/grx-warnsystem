-- MADE BY GRANDØMX#0001 --

WEBHOOK_URL = "" -- Put your discord webhook url here / masukkan url webhook discord

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('es:addGroupCommand', 'warn', 'superadmin', function(source, args, rawCommand)
    local user = tonumber(args[1]) -- player id
    local warning = tonumber(args[2]) -- how many warning you want to give
    local msg = table.concat(args, " ", 3) -- reason
    local warningplayer = warning
    local username = GetPlayerName(user)
    local playername = GetPlayerName(source)

    -- fetching users table to get the identifier & warn total
    local identifier = GetPlayerIdentifiers(user)[1] -- player identifier
    local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", { ['@identifier'] = identifier })

    -- getting identifier & warn data
    local identity = result[1].identifier -- fetch identifier
    local warnpoint = result[1].warn -- fetch warn count
    
    -- executing add point to database 
    local warn = warnpoint + warning
    MySQL.Sync.execute('UPDATE users SET warn = @warn WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['@warn'] = warn
    })
    
    -- send warning to a channel
    warnThisShit(username, msg, "**" .. playername .. "** give **" .. warningplayer .. "** warning to " .. username .. "[" .. identity .. "], total **" .. (warnpoint + warningplayer) .. "** warning, reason **" .. msg .. "**")
    -- TriggerClientEvent('esx:showNotification', source, "Warning Sent!") -- Default notification
    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "Warning Sent!" }) -- notification using mythic_notify

    -- send warning to ingame chat
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(100, 0, 0, 0.4); border-radius: 5px;"><i class="fas fa-first-aid"></i> <b>{0}</b> give <b>{1}</b> warning kepada {2}[{3}], total <b>{4}</b> warning, keterangan <b>{5}</b></div>',
        args = { playername, warningplayer, username, identity, (warnpoint + warningplayer), msg }
	})
end, function(source, args, user)
    TriggerClientEvent('chat:addMessage', source, { args = { '^1FIRSTCLASS', 'No permissions.' } })
end, {help = 'give warning to a player', params = {{name = "id", help = "player id"}, {name = "warn", help = "warn point"}, {name = "reason", help = "warning reason"}}})

function warnThisShit(name, message, type)
  	PerformHttpRequest(WEBHOOK_URL, function(err, text, headers) end, 'POST', json.encode({content = type }), { ['Content-Type'] = 'application/json' })
end
