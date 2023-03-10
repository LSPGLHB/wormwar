function checkShop()
    Timers:CreateTimer(0,function ()
        print("==============checkShop================")
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
               
                local player = PlayerResource:GetPlayer(playerID)
                local hero = player:GetAssignedHero()
                local position = hero:GetAbsOrigin()
                local heroTeam = hero:GetTeam()
                local searchRadius = 200
                local aroundUnits = FindUnitsInRadius(heroTeam, 
                                                    position,
                                                    nil,
                                                    searchRadius,
                                                    DOTA_UNIT_TARGET_TEAM_BOTH,
										            DOTA_UNIT_TARGET_ALL,
                                                    0,
                                                    0,
                                                    false)
                local shopFlag = "close"                                    
                for k,unit in pairs(aroundUnits) do
                    --local name = unit:GetContext("name")
                    local lable =unit:GetUnitLabel()
            
                    local unitTeam = unit:GetTeam()
					
                    if hero ~= unit and unitTeam == heroTeam and  GameRules.shopLabel == lable then
                        print("lable",lable)
                        shopFlag = "open"
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