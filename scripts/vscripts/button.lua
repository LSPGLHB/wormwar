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
    
    local playerStatusAbility={}
    local playerStatusHero = {}
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
        --print("playerID",playerID)
            playerStatusAbility[playerID] = {}
            local abilityNameList = {}
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            local heroName = PlayerResource:GetSelectedHeroName(playerID)
           
            local hAbilityC = hHero:GetAbilityByIndex(3)
            local abilityNameC = hAbilityC:GetAbilityName()
            local hAbilityB = hHero:GetAbilityByIndex(4)
            local abilityNameB = hAbilityB:GetAbilityName()
            local hAbilityA = hHero:GetAbilityByIndex(5)
            local abilityNameA = hAbilityA:GetAbilityName()
            table.insert(abilityNameList,abilityNameC)
            table.insert(abilityNameList,abilityNameB)
            table.insert(abilityNameList,abilityNameA)
            local abilityIconList = getAbilityIconListByNameList(abilityNameList)
            local itemIconList =  getItemIconListByHero(hHero)
            --print("iconList",iconList[1])
           
            playerStatusHero[playerID] = heroName
            playerStatusAbility[playerID] = abilityIconList
            playerStatusItem[playerID] = itemIconList
        end
    end
    
    --print("abilityName",abilityName)
    CustomGameEventManager:Send_ServerToPlayer( myPlayer , "showPlayerStatusLUATOJS", {
        playerStatusHero = playerStatusHero,
        playerStatusAbility = playerStatusAbility,
        playerStatusItem = playerStatusItem
    })
end

function getAbilityIconListByNameList(nameList)
    local abilityList = GameRules.customAbilities
    local abilityIconList = {}

    for i = 1 , #nameList , 1 do
        for key, value in pairs(abilityList) do         
            if( key == nameList[i] ) then
                for k,v in pairs(value) do
                    if(k == "iconSrc") then
                        abilityIconList[i] = v
                    end
                end
            end
        end
    end
    return abilityIconList
end

function getItemIconListByHero(hHero)
    local itemList = GameRules.itemList
    local itemIconList = {}
    for i = 1 , 6 , 1 do
        local item = hHero:GetItemInSlot(i-1)--物品栏从0开始
        local itemName = item:GetName()
        for key, value in pairs(itemList) do
            if(key == itemName) then
                for k, v pairs(value) do
                    if(k == "iconSrc") then
                        itemIconList[i] = v
                    end
                end
            end
        end
    end
    return itemIconList
end