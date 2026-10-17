local ox_inventory = exports.ox_inventory
local isProcessing = {}

-- kirim log ke Discord pas command dipake
local function sendDiscordLog(title, color, fields)
    if not Config.Discord.enabled or not Config.Discord.webhook or Config.Discord.webhook == '' or Config.Discord.webhook == 'ISI_URL_WEBHOOK_DISCORD_KAMU_DISINI' then 
        return 
    end

    local embed = {
        {
            title = title,
            color = color or 3447003,
            fields = fields,
            footer = {
                text = os.date('%d/%m/%Y %H:%M:%S') .. ' | Set Weight Log'
            }
        }
    }

    PerformHttpRequest(Config.Discord.webhook, function() end, 'POST', json.encode({
        username = Config.Discord.botName or 'Log Set Weight',
        avatar_url = Config.Discord.botAvatar or '',
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Pasang berat pas player masuk kota
local function applyPlayerWeight(src)
    if not src or not GetPlayerName(src) or isProcessing[src] then return end
    isProcessing[src] = true

    CreateThread(function()
        local tries = 0
        local inv = ox_inventory:GetInventory(src)

        -- Cek berkala tiap 200ms, max 10x biar ga gantung
        while (not inv or not inv.owner) and tries < 10 do
            Wait(200)
            if not GetPlayerName(src) then 
                isProcessing[src] = nil
                return 
            end
            inv = ox_inventory:GetInventory(src)
            tries = tries + 1
        end

        if inv and inv.owner then
            local steam = GetPlayerIdentifierByType(src, 'steam')
            local rawSteam = steam and steam:gsub('steam:', '')
            local license = GetPlayerIdentifierByType(src, 'license')

            local targetWeight = Config.Weights[inv.owner]
                or (steam and Config.Weights[steam])
                or (rawSteam and Config.Weights[rawSteam])
                or (license and Config.Weights[license])
                or Config.DefaultWeight

            if targetWeight then
                ox_inventory:SetMaxWeight(src, targetWeight)
            end
        end

        isProcessing[src] = nil
    end)
end

-- framework
local fw = string.lower(Config.Framework or 'auto')

if fw == 'esx' or fw == 'auto' then
    AddEventHandler('esx:playerLoaded', function(playerId)
        applyPlayerWeight(playerId)
    end)
end

if fw == 'qb' or fw == 'auto' then
    AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
        applyPlayerWeight(source)
    end)
end

if fw == 'qbx' or fw == 'auto' then
    AddEventHandler('qbx_core:server:playerLoaded', function(player)
        applyPlayerWeight(player?.PlayerData?.source or source)
    end)
end

if fw == 'auto' then
    AddEventHandler('ox:playerLoaded', function(source)
        applyPlayerWeight(source)
    end)
end

-- Kalo script direstart auto kepasang ulang ke yang lagi online
AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Wait(500)
    for _, pid in ipairs(GetPlayers()) do
        applyPlayerWeight(tonumber(pid))
    end
end)

AddEventHandler('playerDropped', function()
    isProcessing[source] = nil
end)

-- command /setweight (LOG DISCORD)
RegisterCommand('setweight', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin', 'developer') then return end

    local target = tonumber(args[1])
    local weight = tonumber(args[2])

    if not target or not weight or not GetPlayerName(target) then
        local msg = 'Formatnya: /setweight [ID Player] [Berat]'
        if source == 0 then print(msg) else
            lib.notify(source, { title = 'Salah Format Bro', description = msg, type = 'error' })
        end
        return
    end

    -- Update berat tas di ox
    ox_inventory:SetMaxWeight(target, weight)

    local adminName = source == 0 and 'Console' or GetPlayerName(source)

    if source ~= 0 then
        lib.notify(source, {
            title = 'Berhasil!',
            description = ('Berat ID %s udah diubah jadi %s'):format(target, weight),
            type = 'success'
        })
    end

    lib.notify(target, {
        title = 'Info Tas',
        description = ('Kapasitas tas lu sekarang jadi %s gram'):format(weight),
        type = 'inform'
    })

    -- kirim log ke Discord
    sendDiscordLog('🛠️ Admin Ganti Berat Tas', 15844367, {
        { name = '👑 Admin', value = ('%s (ID: %s)'):format(adminName, source), inline = true },
        { name = '🎯 Target Player', value = ('%s (ID: %s)'):format(GetPlayerName(target), target), inline = true },
        { name = '⚖️ Kapasitas Baru', value = ('**%s gram** (%.1f KG)'):format(weight, weight / 1000), inline = false }
    })
end, false)