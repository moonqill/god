repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild('CountDown')

print("ZapZone - AFK Notify Loaded [Arise]")

local _request_ = http_request or request or HttpPost or (syn and syn.request)
local player = game.Players.LocalPlayer
local rewardinfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexer"):WaitForChild("RewardInfo"))
local afkreward = player:WaitForChild("leaderstats"):WaitForChild("AfkRewards")
local httpService = game:GetService("HttpService")

local list_description = {
    ['Ziru G'] = 'Ziru G',
    ['Tiger'] = 'Tiger',
    ['Twin Prism Blades'] = 'Twin Prism Blades',
    ['20 COMMON POWDER'] = '20 COMMON POWDER',
    ['20 RARE POWDER'] = '20 RARE POWDER',
    ['20 LEGENDARY POWDER'] = '20 LEGENDARY POWDER'
}
local list_result = {
    ['100 GEMS'] = '100',
    ['500 GEMS'] = '500',
    ['2000 GEMS'] = '2000',
    ['2 TICKETS'] = '2',
    ['5 TICKETS'] = '5',
    ['8 TICKETS'] = '8',
}


local function item_received()
    local item_list = {}
    local gem_total = 0
    local ticket_total = 0 

    for i, v in pairs(afkreward:GetAttributes()) do
        if v then
            local item = rewardinfo[i]
            if item then
                local value = v
                local rarity = item.Chance / 100 

                local is_gem_or_ticket = false
                for name_list, amount in pairs(list_result) do
                    if string.find(item.Name, name_list, 1, true) then
                        local item_value = tonumber(amount) * value
                        if string.find(name_list, "GEMS") then
                            gem_total = gem_total + item_value
                        elseif string.find(name_list, "TICKET") then
                            ticket_total = ticket_total + item_value
                        end
                        is_gem_or_ticket = true
                        break
                    end
                end

                if not is_gem_or_ticket then
                    local display_name = list_description[item.Name] or item.Name
                    table.insert(item_list, {
                        name = display_name, 
                        value = value,
                        rarity = rarity
                    })
                end
            end
        end
    end

    if gem_total > 0 then
        table.insert(item_list, {
            name = "Gems",
            value = gem_total,
            rarity = 10 
        })
    end
    if ticket_total > 0 then
        table.insert(item_list, {
            name = "Tickets",
            value = ticket_total,
            rarity = 11
        })
    end

    -- เรียงตาม rarity
    table.sort(item_list, function(a, b)
        return a.rarity < b.rarity
    end)

    return item_list
end


local function discord_notify(rewards)
    local rewardsText = ""
    for _, reward in ipairs(rewards) do
        rewardsText = rewardsText .. "➟ " .. reward.name .. " x" .. reward.value .. "\n"
    end
    
    local embedData = {
        color = tonumber(_G.colorEmbed),
        author = {
            name = "# Arise Crossover"
        },
        fields = {
            {
                name = "**__Account - Information__**",
                value = "➟ Roblox Username: || " .. player.Name .. "||"
            },
            {
                name = "**__Rewards - ของที่ได้รับ__**",
                value = rewardsText
            }
        },
        image = {
            url = tostring(_G.banerUrl)
        }
    }
    
    local payload = {
        username = tostring(_G.avatarName),
        avatar_url = tostring(_G.avatarUrl),
        embeds = {embedData}
    }
    
    local jsonPayload = httpService:JSONEncode(payload)
    
    local response = _request_({
        Url = tostring(_G.webhookUrl),
        Body = jsonPayload,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        }
    })
    
    print("Webhook response:", response.Body)
end

task.spawn(function()
    while true do task.wait(5)
        local success, err = pcall(function()
            local rewards = item_received()
            if #rewards > 0 then
                discord_notify(rewards)
                print("Notification sent with " .. #rewards .. " rewards")
            else
                print("No rewards found to report")
            end
        end)
        if not success then
            warn(`error: {tostring(err)}`)
        end
    end
end)
print("Loaded Success!")
