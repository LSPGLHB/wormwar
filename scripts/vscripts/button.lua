require('shop')
function initShopStats()
    --初始化第一批商店列表
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			refreshShopList(playerID)
        end
    end

    Timers:CreateTimer(0,function ()
        --print("==============checkShop================")
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
                local player = PlayerResource:GetPlayer(playerID)
                local hero = player:GetAssignedHero()
                local position = hero:GetAbsOrigin()
                local heroTeam = hero:GetTeam()
                local searchRadius = 500
                local shopFlag = "unkown"  
                local aroundUnits = FindUnitsInRadius(heroTeam, 
                                                    position,
                                                    nil,
                                                    searchRadius,
                                                    DOTA_UNIT_TARGET_TEAM_BOTH,
										            DOTA_UNIT_TARGET_ALL,
                                                    0,
                                                    0,
                                                    false)             
                for k,unit in pairs(aroundUnits) do
                    --local name = unit:GetContext("name")
                    local lable =unit:GetUnitLabel()
                    local unitTeam = unit:GetTeam()		
                    if hero ~= unit and unitTeam == heroTeam and  GameRules.shopLabel == lable then
                        --print("lable",lable)
                        shopFlag = "active"
                    end
                end
                CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "checkShopLUATOJS", {
                    flag = shopFlag
                })
            end
        end
        return 1
    end)
end

function openShopJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    local player = PlayerResource:GetPlayer(playerID)
    OnMyUIShopOpen(playerID)
    getPlayerShopListByRandomList(playerID, player.randomItemNumList)
    
end

function closeShopJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    OnMyUIShopClose(playerID)
end

function refreshShopJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    refreshShopList(playerID)
end


function refreshShopList(playerID)
    local itemNameList = GameRules.itemNameList
    local count = #itemNameList
    --print("itemNameList=====================",count)
    local randomItemNumList= getRandomNumList(1,count,3)
    --print("randomItemNumList",#randomItemNumList)
    local player = PlayerResource:GetPlayer(playerID)
    player.randomItemNumList = randomItemNumList
end