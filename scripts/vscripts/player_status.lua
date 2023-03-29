--玩家信息显示
function OnMyUIPlayerStatusOpen( playerID )
    CustomUI:DynamicHud_Create(playerID,"UIPlayerStatusPanelBG","file://{resources}/layout/custom_game/UI_player_status.xml",nil)
end

function OnMyUIPlayerStatusClose(playerID)
	CustomUI:DynamicHud_Destroy(playerID,"UIPlayerStatusPanelBG")
end

function  showPlayerStatusPanel( myPlayerID )
    local playerStatusHero = {}
    local playerStatusAbility = {}
    local playerStatusItem = {}
    for i=0,9,1  do
        playerStatusHero[i] = "nil"
        playerStatusAbility[i]={}
        playerStatusItem[i] ={}
        for j=0,3,1 do
            playerStatusAbility[i][j] = "nil"
        end
        for k=0,8,1 do
            playerStatusItem[i][k] = "nil"
        end
    end
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
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
            playerStatusHero[playerID] = heroName
            playerStatusAbility[playerID] = abilityIconList
            playerStatusItem[playerID] = itemIconList
        end
    end
    local myPlayer = PlayerResource:GetPlayer(myPlayerID)
    CustomGameEventManager:Send_ServerToPlayer( myPlayer , "openPlayerStatusLUATOJS", {  
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
        if (item~=nil) then
            local itemName = item:GetName()
           -- print("itemName",itemName)
            for key, value in pairs(itemList) do
                if(key == itemName) then
                    --print("key",key)
                    for k, v in pairs(value) do
                        if(k == "IconSrc") then
                            --print("IconSrc",v)
                            itemIconList[i] = v
                        end
                    end
                end
            end
        end
    end
    return itemIconList
end


function refreshPlayerStatus(playerID)
    local player = PlayerResource:GetPlayer(playerID)
    Timers:CreateTimer(0,function ()
        if(player.playerStatusShow) then
            OnMyUIPlayerStatusClose(playerID)
            OnMyUIPlayerStatusOpen( playerID )
            showPlayerStatusPanel( playerID )
            return 1
        end
        return nil
    end)


    
end