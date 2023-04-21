require('player_power')
function modifier_item_sacrificial_robe_on_created(keys)
    print("onCreated")
end

function modifier_item_sacrificial_robe_on_destroy(keys)
    print("onDestroy")
end

function modifier_item_sacrificial_robe_on_death(keys)
    print("onDeath")
    refreshTeamItemBuff(keys)
end
function modifier_item_sacrificial_robe_on_respawn(keys) 
    print("onRespawn")
    --refreshTeamItemBuff(keys)
end
--需要联机测试
--每局结束需要初始化临时数据
function refreshTeamItemBuff(keys)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local deathTeam = caster:GetTeam()

    
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            local player = PlayerResource:GetPlayer(playerID)
            local playerTeam = player:GetTeam()
            if (deathTeam == playerTeam) then
                setTeamBuffValue(keys,player)
            end
        end
    end
end

function setTeamBuffValue(keys,player)
    local playerID = player:GetPlayerID()
    --local caster = keys.caster
    local ability = keys.ability
    local team_vision_after_die = ability:GetSpecialValueFor( "team_vision_after_die")

    
    setPlayerPower(playerID, "temp_vision" , true, team_vision_after_die)


    setPlayerBuffByIDNameBValue(keys,player,"vision",GameRules.playerBaseVision)



end

function setPlayerBuffByIDNameBValue(keys,player,buffName,baseValue)
    --local caster = keys.caster
    local playerID = player:GetPlayerID()
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)

    local modifierName = "temp_"..buffName
    local abilityName = "ability_"..buffName.."_control_temp"
    local modifierNameBuff = "modifier_"..buffName.."_buff_temp"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff_temp"
    local modifierStackCount =  getPlayerPowerValueByName(player, modifierName, baseValue)

    setPlayerBuffByAbilityAndModifier(hHero, abilityName, modifierNameBuff, modifierNameDebuff, modifierStackCount)
    
   
end