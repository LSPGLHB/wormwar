require('shop')
require('player_status')
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
                local searchRadius = 700
                local shopFlag = "unkown"  
                local playerGold = PlayerResource:GetGold(playerID)
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
                    local lable =unit:GetUnitLabel()
                    local unitTeam = unit:GetTeam()		
                    if hero ~= unit and unitTeam == heroTeam and  GameRules.shopLabel == lable then
                        shopFlag = "active"
                    end
                end
                CustomGameEventManager:Send_ServerToPlayer( player , "checkShopLUATOJS", {
                    flag = shopFlag,
                    playerGold = playerGold
                })
            end
        end
        return 0.3
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
    local player = PlayerResource:GetPlayer(playerID)
    refreshShopList(playerID)
    OnMyUIShopClose(playerID)
    OnMyUIShopOpen(playerID)
    getPlayerShopListByRandomList(playerID, player.randomItemNumList)
end


function refreshShopList(playerID)
    local itemNameList = GameRules.itemNameList
    local count = #itemNameList
    --print("itemNameList=====================",count)
    local randomItemNumList= getRandomNumList(1,count,6)
    --print("randomItemNumList",#randomItemNumList)
    local player = PlayerResource:GetPlayer(playerID)
    player.randomItemNumList = randomItemNumList
end



function openPlayerStatusJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    local myPlayer = PlayerResource:GetPlayer(myPlayerID)
    myPlayer.playerStatusShow = true
    OnMyUIPlayerStatusOpen( myPlayerID )
    showPlayerStatusPanel( myPlayerID )  
    refreshPlayerStatus(myPlayerID) 
end

function closePlayerStatusJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    local myPlayer = PlayerResource:GetPlayer(myPlayerID)
    myPlayer.playerStatusShow = false
    OnMyUIPlayerStatusClose(myPlayerID)
end

