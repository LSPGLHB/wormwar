--永久类modifier，天赋与装备专用
function setPlayerBuffByNameAndBValue(hero,buffName,baseValue)
    --local caster = keys.caster
    local modifierName = "player_"..buffName
    local abilityName = "ability_"..buffName.."_control"
    local modifierNameBuff = "modifier_"..buffName.."_buff"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff"
    local modifierStackCount =  getPlayerPowerValueByName(hero, modifierName, baseValue)
    setPlayerBuffByAbilityAndModifier(hero, abilityName, modifierNameBuff, modifierNameDebuff, modifierStackCount)
end

function setPlayerBuffByAbilityAndModifier(hero, abilityName, modifierNameBuff, modifierNameDebuff, modifierStackCount)
    --local caster = keys.caster
    --local playerID = caster:GetPlayerID()
    --local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    --local player = PlayerResource:GetPlayer(playerID)
    local modifierNameAdd
    local modifierNameRemove
    --print("setPlayerBuffByAbilityAndModifier",abilityName)
    --print(modifierNameBuff,"==",modifierNameDebuff)
    removePlayerBuffByAbilityAndModifier(hero, abilityName, modifierNameBuff,modifierNameDebuff)
    if (modifierStackCount ~= 0) then 
        hero:AddAbility(abilityName):SetLevel(1)
        if (modifierStackCount > 0) then
            modifierNameAdd = modifierNameBuff
            modifierNameRemove = modifierNameDebuff
        else
            modifierNameAdd = modifierNameDebuff
            modifierNameRemove = modifierNameBuff
            modifierStackCount = modifierStackCount * -1
        end
        print("modifierNameRemove",modifierNameRemove)
        print("modifierNameAdd",modifierNameAdd,"=",modifierStackCount)
        hero:RemoveModifierByName(modifierNameRemove)
        hero:SetModifierStackCount(modifierNameAdd, hero, modifierStackCount)
    end
end

--条件触发，有持续时间的modifier
function setPlayerDurationBuffByName(keys,buffName)
    local caster = keys.caster
    local playerID = caster:GetPlayerID()
    print("setPlayerDurationBuffByName",buffName)
    if (PlayerPower[playerID]['player_'..buffName..'_duration'] > 0 and PlayerPower[playerID]['player_'..buffName..'_flag'] == 1) then
        local modifierName = "duration_"..buffName
        local abilityName = "ability_"..buffName.."_control_duration"
        local modifierNameBuff = "modifier_"..buffName.."_buff_duration"  
        local modifierNameDebuff = "modifier_"..buffName.."_debuff_duration"
        initPlayerDurationBuff(keys, abilityName, modifierNameBuff, modifierNameDebuff)
    end
end

--条件触发，有持续时间的modifier
function initPlayerDurationBuff(keys, abilityName, modifierNameBuff, modifierNameDebuff)
    print("initPlayerDurationBuff",abilityName)
    local caster = keys.caster
    removePlayerBuffByAbilityAndModifier(caster, abilityName, modifierNameBuff,modifierNameDebuff)
    if (modifierStackCount ~= 0) then 
        caster:AddAbility(abilityName):SetLevel(1)
    end
end
--条件触发，有持续时间的modifier
function setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local modifierName = "duration_"..buffName
    --local abilityName = "ability_"..buffName.."_control_duration"
    local modifierNameBuff = "modifier_"..buffName.."_buff_duration"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff_duration"
    local modifierStackCount =  getPlayerPowerValueByName(caster, modifierName, baseValue)
    local modifierDuration = PlayerPower[playerID]['player_'..buffName..'_duration']
    
    local modifierNameAdd
    local modifierNameRemove

    if (modifierStackCount > 0) then
        modifierNameAdd = modifierNameBuff
        modifierNameRemove = modifierNameDebuff
    else
        modifierNameAdd = modifierNameDebuff
        modifierNameRemove = modifierNameBuff
        modifierStackCount = modifierStackCount * -1
    end
    print("setPlayerDurationBuffByAbilityAndModifier",modifierNameAdd,"==",modifierStackCount)
    print("=======================================")
    caster:RemoveModifierByName(modifierNameRemove)
    ability:ApplyDataDrivenModifier( caster, caster, modifierNameAdd, {duration = modifierDuration} )
    caster:SetModifierStackCount(modifierNameAdd, caster, modifierStackCount)
end


function removePlayerBuffByAbilityAndModifier(hero, abilityName, modifierNameBuff,modifierNameDebuff)
    --print("hero",hero)
    if (hero:HasAbility(abilityName)) then
        hero:RemoveAbility(abilityName)
    end
    if(hero:HasModifier(modifierNameBuff)) then
        hero:RemoveModifierByName(modifierNameBuff)
    end
    if(hero:HasModifier(modifierNameDebuff)) then
        hero:RemoveModifierByName(modifierNameDebuff)
    end
end

function setPlayerPower(playerID, powerName, isAdd, value)
    print("setPlayerPower",playerID)
    print(powerName.."=="..value)
    if( not isAdd ) then
        value = value * -1
    end
    PlayerPower[playerID][powerName] = PlayerPower[playerID][powerName] + value
end

function setPlayerPowerFlag(playerID, powerName, value)
    print("setPlayerPowerFlag")
    PlayerPower[playerID][powerName] = value
end

--获取Modifiers层数值
function getPlayerPowerValueByName(hero, powerName, playerBaseValue)
    --local caster = keys.caster
    local playerID = hero:GetPlayerID()
    --print("getPlayerPowerValueByName",playerID,powerName,playerBaseValue)
    local precentBaseBuff = powerName .. "_precent_base"
    local precentFinalBuff = powerName .. "_precent_final"

    local powerValue = PlayerPower[playerID][powerName]
    local precentBaseValue = PlayerPower[playerID][precentBaseBuff] / 100
    local precentFinalValue = PlayerPower[playerID][precentFinalBuff] /100
    --print(powerValue,precentBaseValue,precentFinalValue)

    local stackCount = (playerBaseValue * (1 + precentBaseValue) + powerValue ) * (1 + precentFinalValue) - playerBaseValue
    --print(powerName,"=stackCount=",stackCount)

    return stackCount
end






function initPlayerPower()
    PlayerPower={}


    for i = 0, 9 do --10个玩家的数据包
        PlayerPower[i] = {} 
        --Modifiers能力
        PlayerPower[i]['player_vision'] = 0
        PlayerPower[i]['player_vision_precent_base'] = 0
        PlayerPower[i]['player_vision_precent_final'] = 0
        PlayerPower[i]['temp_vision'] = 0
        PlayerPower[i]['temp_vision_precent_base'] = 0
        PlayerPower[i]['temp_vision_precent_final'] = 0
        PlayerPower[i]['duration_vision'] = 0
        PlayerPower[i]['duration_vision_precent_base'] = 0
        PlayerPower[i]['duration_vision_precent_final'] = 0
        PlayerPower[i]['player_vision_duration'] = 0        
        PlayerPower[i]['player_vision_flag'] = 1

        PlayerPower[i]['player_speed'] = 0
        PlayerPower[i]['player_speed_precent_base'] = 0
        PlayerPower[i]['player_speed_precent_final'] = 0
        PlayerPower[i]['temp_speed'] = 0
        PlayerPower[i]['temp_speed_precent_base'] = 0
        PlayerPower[i]['temp_speed_precent_final'] = 0
        PlayerPower[i]['duration_speed'] = 0
        PlayerPower[i]['duration_speed_precent_base'] = 0
        PlayerPower[i]['duration_speed_precent_final'] = 0
        PlayerPower[i]['player_speed_duration'] = 0   
        PlayerPower[i]['player_speed_flag'] = 1
        

        PlayerPower[i]['player_health'] = 0     
        PlayerPower[i]['player_health_precent_base'] = 0
        PlayerPower[i]['player_health_precent_final'] = 0
        PlayerPower[i]['temp_health'] = 0     
        PlayerPower[i]['temp_health_precent_base'] = 0
        PlayerPower[i]['ptemp_health_precent_final'] = 0
        PlayerPower[i]['duration_health'] = 0     
        PlayerPower[i]['duration_health_precent_base'] = 0
        PlayerPower[i]['duration_health_precent_final'] = 0
        PlayerPower[i]['player_health_duration'] = 0      
        PlayerPower[i]['player_health_flag'] = 1

        PlayerPower[i]['player_mana'] = 0     
        PlayerPower[i]['player_mana_precent_base'] = 0
        PlayerPower[i]['player_mana_precent_final'] = 0
        PlayerPower[i]['temp_mana'] = 0     
        PlayerPower[i]['temp_mana_precent_base'] = 0
        PlayerPower[i]['temp_mana_precent_final'] = 0
        PlayerPower[i]['duration_mana'] = 0     
        PlayerPower[i]['duration_mana_precent_base'] = 0
        PlayerPower[i]['duration_mana_precent_final'] = 0
        PlayerPower[i]['player_mana_duration'] = 0
        PlayerPower[i]['player_mana_flag'] = 1

        PlayerPower[i]['player_mana_regen'] = 0     
        PlayerPower[i]['player_mana_regen_precent_base'] = 0
        PlayerPower[i]['player_mana_regen_precent_final'] = 0
        PlayerPower[i]['temp_mana_regen'] = 0     
        PlayerPower[i]['temp_mana_regen_precent_base'] = 0
        PlayerPower[i]['temp_mana_regen_precent_final'] = 0
        PlayerPower[i]['duration_mana_regen'] = 0     
        PlayerPower[i]['duration_mana_regen_precent_base'] = 0
        PlayerPower[i]['duration_mana_regen_precent_final'] = 0
        PlayerPower[i]['player_mana_regen_duration'] = 0
        PlayerPower[i]['player_mana_regen_flag'] = 1


        --技能能力
        PlayerPower[i]['player_ability_speed_D'] = 0
        PlayerPower[i]['player_ability_speed_D_precent_base'] = 0
        PlayerPower[i]['player_ability_speed_D_precent_final'] = 0
        PlayerPower[i]['player_ability_speed_C'] = 0
        PlayerPower[i]['player_ability_speed_C_precent_base'] = 0
        PlayerPower[i]['player_ability_speed_C_precent_final'] = 0
        PlayerPower[i]['player_ability_speed_B'] = 0
        PlayerPower[i]['player_ability_speed_B_precent_base'] = 0
        PlayerPower[i]['player_ability_speed_B_precent_final'] = 0
        PlayerPower[i]['player_ability_speed_A'] = 0
        PlayerPower[i]['player_ability_speed_A_precent_base'] = 0
        PlayerPower[i]['player_ability_speed_A_precent_final'] = 0
        PlayerPower[i]['temp_ability_speed_D'] = 0
        PlayerPower[i]['temp_ability_speed_D_precent_base'] = 0
        PlayerPower[i]['temp_ability_speed_D_precent_final'] = 0
        PlayerPower[i]['temp_ability_speed_C'] = 0
        PlayerPower[i]['temp_ability_speed_C_precent_base'] = 0
        PlayerPower[i]['temp_ability_speed_C_precent_final'] = 0
        PlayerPower[i]['temp_ability_speed_B'] = 0
        PlayerPower[i]['temp_ability_speed_B_precent_base'] = 0
        PlayerPower[i]['temp_ability_speed_B_precent_final'] = 0
        PlayerPower[i]['temp_ability_speed_A'] = 0
        PlayerPower[i]['temp_ability_speed_A_precent_base'] = 0
        PlayerPower[i]['temp_ability_speed_A_precent_final'] = 0
        PlayerPower[i]['duration_ability_speed_D'] = 0
        PlayerPower[i]['duration_ability_speed_D_precent_base'] = 0
        PlayerPower[i]['duration_ability_speed_D_precent_final'] = 0
        PlayerPower[i]['duration_ability_speed_C'] = 0
        PlayerPower[i]['duration_ability_speed_C_precent_base'] = 0
        PlayerPower[i]['duration_ability_speed_C_precent_final'] = 0
        PlayerPower[i]['duration_ability_speed_B'] = 0
        PlayerPower[i]['duration_ability_speed_B_precent_base'] = 0
        PlayerPower[i]['duration_ability_speed_B_precent_final'] = 0
        PlayerPower[i]['duration_ability_speed_A'] = 0
        PlayerPower[i]['duration_ability_speed_A_precent_base'] = 0
        PlayerPower[i]['duration_ability_speed_A_precent_final'] = 0
        PlayerPower[i]['player_ability_speed_duration'] = 0
        PlayerPower[i]['player_ability_speed_flag'] = 1

        PlayerPower[i]['player_range_D'] = 0
        PlayerPower[i]['player_range_D_precent_base'] = 0
        PlayerPower[i]['player_range_D_precent_final'] = 0
        PlayerPower[i]['player_range_C'] = 0
        PlayerPower[i]['player_range_C_precent_base'] = 0
        PlayerPower[i]['player_range_C_precent_final'] = 0
        PlayerPower[i]['player_range_B'] = 0
        PlayerPower[i]['player_range_B_precent_base'] = 0
        PlayerPower[i]['player_range_B_precent_final'] = 0
        PlayerPower[i]['player_range_A'] = 0
        PlayerPower[i]['player_range_A_precent_base'] = 0
        PlayerPower[i]['player_range_A_precent_final'] = 0
        PlayerPower[i]['temp_range_D'] = 0
        PlayerPower[i]['temp_range_D_precent_base'] = 0
        PlayerPower[i]['temp_range_D_precent_final'] = 0
        PlayerPower[i]['temp_range_C'] = 0
        PlayerPower[i]['temp_range_C_precent_base'] = 0
        PlayerPower[i]['temp_range_C_precent_final'] = 0
        PlayerPower[i]['temp_range_B'] = 0
        PlayerPower[i]['temp_range_B_precent_base'] = 0
        PlayerPower[i]['temp_range_B_precent_final'] = 0
        PlayerPower[i]['temp_range_A'] = 0
        PlayerPower[i]['temp_range_A_precent_base'] = 0
        PlayerPower[i]['temp_range_A_precent_final'] = 0
        PlayerPower[i]['duration_range_D'] = 0
        PlayerPower[i]['duration_range_D_precent_base'] = 0
        PlayerPower[i]['duration_range_D_precent_final'] = 0
        PlayerPower[i]['duration_range_C'] = 0
        PlayerPower[i]['duration_range_C_precent_base'] = 0
        PlayerPower[i]['duration_range_C_precent_final'] = 0
        PlayerPower[i]['duration_range_B'] = 0
        PlayerPower[i]['duration_range_B_precent_base'] = 0
        PlayerPower[i]['duration_range_B_precent_final'] = 0
        PlayerPower[i]['duration_range_A'] = 0
        PlayerPower[i]['duration_range_A_precent_base'] = 0
        PlayerPower[i]['duration_range_A_precent_final'] = 0
        PlayerPower[i]['player_range_duration'] = 0
        PlayerPower[i]['player_range_flag'] = 1

        PlayerPower[i]['player_mana_cost_D'] = 0
        PlayerPower[i]['player_mana_cost_D_precent'] = 0
        PlayerPower[i]['player_mana_cost_C'] = 0
        PlayerPower[i]['player_mana_cost_C_precent'] = 0
        PlayerPower[i]['player_mana_cost_B'] = 0
        PlayerPower[i]['player_mana_cost_B_precent'] = 0
        PlayerPower[i]['player_mana_cost_A'] = 0
        PlayerPower[i]['player_mana_cost_A_precent'] = 0
        PlayerPower[i]['temp_mana_cost_D'] = 0
        PlayerPower[i]['temp_mana_cost_D_precent'] = 0
        PlayerPower[i]['temp_mana_cost_C'] = 0
        PlayerPower[i]['temp_mana_cost_C_precent'] = 0
        PlayerPower[i]['temp_mana_cost_B'] = 0
        PlayerPower[i]['temp_mana_cost_B_precent'] = 0
        PlayerPower[i]['temp_mana_cost_A'] = 0
        PlayerPower[i]['temp_mana_cost_A_precent'] = 0
        PlayerPower[i]['duration_mana_cost_D'] = 0
        PlayerPower[i]['duration_mana_cost_D_precent'] = 0
        PlayerPower[i]['duration_mana_cost_C'] = 0
        PlayerPower[i]['duration_mana_cost_C_precent'] = 0
        PlayerPower[i]['duration_mana_cost_B'] = 0
        PlayerPower[i]['duration_mana_cost_B_precent'] = 0
        PlayerPower[i]['duration_mana_cost_A'] = 0
        PlayerPower[i]['duration_mana_cost_A_precent'] = 0
        PlayerPower[i]['player_mana_cost_duration'] = 0

        PlayerPower[i]['player_damage_D'] = 0
        PlayerPower[i]['player_damage_D_precent_base'] = 0
        PlayerPower[i]['player_damage_D_precent_final'] = 0
        PlayerPower[i]['player_damage_C'] = 0
        PlayerPower[i]['player_damage_C_precent_base'] = 0
        PlayerPower[i]['player_damage_C_precent_final'] = 0
        PlayerPower[i]['player_damage_B'] = 0
        PlayerPower[i]['player_damage_B_precent_base'] = 0
        PlayerPower[i]['player_damage_B_precent_final'] = 0
        PlayerPower[i]['player_damage_A'] = 0
        PlayerPower[i]['player_damage_A_precent_base'] = 0
        PlayerPower[i]['player_damage_A_precent_final'] = 0
        PlayerPower[i]['temp_damage_D'] = 0
        PlayerPower[i]['temp_damage_D_precent_base'] = 0
        PlayerPower[i]['temp_damage_D_precent_final'] = 0
        PlayerPower[i]['temp_damage_C'] = 0
        PlayerPower[i]['temp_damage_C_precent_base'] = 0
        PlayerPower[i]['temp_damage_C_precent_final'] = 0
        PlayerPower[i]['temp_damage_B'] = 0
        PlayerPower[i]['temp_damage_B_precent_base'] = 0
        PlayerPower[i]['temp_damage_B_precent_final'] = 0
        PlayerPower[i]['temp_damage_A'] = 0
        PlayerPower[i]['temp_damage_A_precent_base'] = 0
        PlayerPower[i]['temp_damage_A_precent_final'] = 0
        PlayerPower[i]['duration_damage_D'] = 0
        PlayerPower[i]['duration_damage_D_precent_base'] = 0
        PlayerPower[i]['duration_damage_D_precent_final'] = 0
        PlayerPower[i]['duration_damage_C'] = 0
        PlayerPower[i]['duration_damage_C_precent_base'] = 0
        PlayerPower[i]['duration_damage_C_precent_final'] = 0
        PlayerPower[i]['duration_damage_B'] = 0
        PlayerPower[i]['duration_damage_B_precent_base'] = 0
        PlayerPower[i]['duration_damage_B_precent_final'] = 0
        PlayerPower[i]['duration_damage_A'] = 0
        PlayerPower[i]['duration_damage_A_precent_base'] = 0
        PlayerPower[i]['duration_damage_A_precent_final'] = 0
        PlayerPower[i]['player_damage_duration'] = 0
        PlayerPower[i]['player_damage_flag'] = 1

        PlayerPower[i]['player_damage_match_D'] = 0
        PlayerPower[i]['player_damage_match_D_precent_base'] = 0
        PlayerPower[i]['player_damage_match_D_precent_final'] = 0
        PlayerPower[i]['player_damage_match_C'] = 0
        PlayerPower[i]['player_damage_match_C_precent_base'] = 0
        PlayerPower[i]['player_damage_match_C_precent_final'] = 0
        PlayerPower[i]['player_damage_match_B'] = 0
        PlayerPower[i]['player_damage_match_B_precent_base'] = 0
        PlayerPower[i]['player_damage_match_B_precent_final'] = 0
        PlayerPower[i]['player_damage_match_A'] = 0
        PlayerPower[i]['player_damage_match_A_precent_base'] = 0
        PlayerPower[i]['player_damage_match_A_precent_final'] = 0
        PlayerPower[i]['temp_damage_match_D'] = 0
        PlayerPower[i]['temp_damage_match_D_precent_base'] = 0
        PlayerPower[i]['temp_damage_match_D_precent_final'] = 0
        PlayerPower[i]['temp_damage_match_C'] = 0
        PlayerPower[i]['temp_damage_match_C_precent_base'] = 0
        PlayerPower[i]['temp_damage_match_C_precent_final'] = 0
        PlayerPower[i]['temp_damage_match_B'] = 0
        PlayerPower[i]['temp_damage_match_B_precent_base'] = 0
        PlayerPower[i]['temp_damage_match_B_precent_final'] = 0
        PlayerPower[i]['temp_damage_match_A'] = 0
        PlayerPower[i]['temp_damage_match_A_precent_base'] = 0
        PlayerPower[i]['temp_damage_match_A_precent_final'] = 0
        PlayerPower[i]['duration_damage_match_D'] = 0
        PlayerPower[i]['duration_damage_match_D_precent_base'] = 0
        PlayerPower[i]['duration_damage_match_D_precent_final'] = 0
        PlayerPower[i]['duration_damage_match_C'] = 0
        PlayerPower[i]['duration_damage_match_C_precent_base'] = 0
        PlayerPower[i]['duration_damage_match_C_precent_final'] = 0
        PlayerPower[i]['duration_damage_match_B'] = 0
        PlayerPower[i]['duration_damage_match_B_precent_base'] = 0
        PlayerPower[i]['duration_damage_match_B_precent_final'] = 0
        PlayerPower[i]['duration_damage_match_A'] = 0
        PlayerPower[i]['duration_damage_match_A_precent_base'] = 0
        PlayerPower[i]['duration_damage_match_A_precent_final'] = 0
        PlayerPower[i]['player_damage_match_duration'] = 0
        PlayerPower[i]['player_damage_match_flag'] = 1

        PlayerPower[i]['player_control_D'] = 0
        PlayerPower[i]['player_control_D_precent_base'] = 0
        PlayerPower[i]['player_control_D_precent_final'] = 0
        PlayerPower[i]['player_control_C'] = 0
        PlayerPower[i]['player_control_C_precent_base'] = 0
        PlayerPower[i]['player_control_C_precent_final'] = 0
        PlayerPower[i]['player_control_B'] = 0
        PlayerPower[i]['player_control_B_precent_base'] = 0
        PlayerPower[i]['player_control_B_precent_final'] = 0
        PlayerPower[i]['player_control_A'] = 0
        PlayerPower[i]['player_control_A_precent_base'] = 0
        PlayerPower[i]['player_control_A_precent_final'] = 0
        PlayerPower[i]['temp_control_D'] = 0
        PlayerPower[i]['temp_control_D_precent_base'] = 0
        PlayerPower[i]['temp_control_D_precent_final'] = 0
        PlayerPower[i]['temp_control_C'] = 0
        PlayerPower[i]['temp_control_C_precent_base'] = 0
        PlayerPower[i]['temp_control_C_precent_final'] = 0
        PlayerPower[i]['temp_control_B'] = 0
        PlayerPower[i]['temp_control_B_precent_base'] = 0
        PlayerPower[i]['temp_control_B_precent_final'] = 0
        PlayerPower[i]['temp_control_A'] = 0
        PlayerPower[i]['temp_control_A_precent_base'] = 0
        PlayerPower[i]['temp_control_A_precent_final'] = 0
        PlayerPower[i]['duration_control_D'] = 0
        PlayerPower[i]['duration_control_D_precent_base'] = 0
        PlayerPower[i]['duration_control_D_precent_final'] = 0
        PlayerPower[i]['duration_control_C'] = 0
        PlayerPower[i]['duration_control_C_precent_base'] = 0
        PlayerPower[i]['duration_control_C_precent_final'] = 0
        PlayerPower[i]['duration_control_B'] = 0
        PlayerPower[i]['duration_control_B_precent_base'] = 0
        PlayerPower[i]['duration_control_B_precent_final'] = 0
        PlayerPower[i]['duration_control_A'] = 0
        PlayerPower[i]['duration_control_A_precent_base'] = 0
        PlayerPower[i]['duration_control_A_precent_final'] = 0
        PlayerPower[i]['player_control_duration'] = 0
        PlayerPower[i]['player_control_flag'] = 1

        PlayerPower[i]['player_control_match_D'] = 0
        PlayerPower[i]['player_control_match_D_precent_base'] = 0
        PlayerPower[i]['player_control_match_D_precent_final'] = 0
        PlayerPower[i]['player_control_match_C'] = 0
        PlayerPower[i]['player_control_match_C_precent_base'] = 0
        PlayerPower[i]['player_control_match_C_precent_final'] = 0
        PlayerPower[i]['player_control_match_B'] = 0
        PlayerPower[i]['player_control_match_B_precent_base'] = 0
        PlayerPower[i]['player_control_match_B_precent_final'] = 0
        PlayerPower[i]['player_control_match_A'] = 0
        PlayerPower[i]['player_control_match_A_precent_base'] = 0
        PlayerPower[i]['player_control_match_A_precent_final'] = 0
        PlayerPower[i]['temp_control_match_D'] = 0
        PlayerPower[i]['temp_control_match_D_precent_base'] = 0
        PlayerPower[i]['temp_control_match_D_precent_final'] = 0
        PlayerPower[i]['temp_control_match_C'] = 0
        PlayerPower[i]['temp_control_match_C_precent_base'] = 0
        PlayerPower[i]['temp_control_match_C_precent_final'] = 0
        PlayerPower[i]['temp_control_match_B'] = 0
        PlayerPower[i]['temp_control_match_B_precent_base'] = 0
        PlayerPower[i]['temp_control_match_B_precent_final'] = 0
        PlayerPower[i]['temp_control_match_A'] = 0
        PlayerPower[i]['temp_control_match_A_precent_base'] = 0
        PlayerPower[i]['temp_control_match_A_precent_final'] = 0
        PlayerPower[i]['duration_control_match_D'] = 0
        PlayerPower[i]['duration_control_match_D_precent_base'] = 0
        PlayerPower[i]['duration_control_match_D_precent_final'] = 0
        PlayerPower[i]['duration_control_match_C'] = 0
        PlayerPower[i]['duration_control_match_C_precent_base'] = 0
        PlayerPower[i]['duration_control_match_C_precent_final'] = 0
        PlayerPower[i]['duration_control_match_B'] = 0
        PlayerPower[i]['duration_control_match_B_precent_base'] = 0
        PlayerPower[i]['duration_control_match_B_precent_final'] = 0
        PlayerPower[i]['duration_control_match_A'] = 0
        PlayerPower[i]['duration_control_match_A_precent_base'] = 0
        PlayerPower[i]['duration_control_match_A_precent_final'] = 0
        PlayerPower[i]['player_control_match_duration'] = 0
        PlayerPower[i]['player_control_match_flag'] = 1
        
        PlayerPower[i]['player_energy_D'] = 0
        PlayerPower[i]['player_energy_D_precent_base'] = 0
        PlayerPower[i]['player_energy_D_precent_final'] = 0
        PlayerPower[i]['player_energy_C'] = 0
        PlayerPower[i]['player_energy_C_precent_base'] = 0
        PlayerPower[i]['player_energy_C_precent_final'] = 0
        PlayerPower[i]['player_energy_B'] = 0
        PlayerPower[i]['player_energy_B_precent_base'] = 0
        PlayerPower[i]['player_energy_B_precent_final'] = 0
        PlayerPower[i]['player_energy_A'] = 0
        PlayerPower[i]['player_energy_A_precent_base'] = 0
        PlayerPower[i]['player_energy_A_precent_final'] = 0
        PlayerPower[i]['temp_energy_D'] = 0
        PlayerPower[i]['temp_energy_D_precent_base'] = 0
        PlayerPower[i]['temp_energy_D_precent_final'] = 0
        PlayerPower[i]['temp_energy_C'] = 0
        PlayerPower[i]['temp_energy_C_precent_base'] = 0
        PlayerPower[i]['temp_energy_C_precent_final'] = 0
        PlayerPower[i]['temp_energy_B'] = 0
        PlayerPower[i]['temp_energy_B_precent_base'] = 0
        PlayerPower[i]['temp_energy_B_precent_final'] = 0
        PlayerPower[i]['temp_energy_A'] = 0
        PlayerPower[i]['temp_energy_A_precent_base'] = 0
        PlayerPower[i]['temp_energy_A_precent_final'] = 0
        PlayerPower[i]['duration_energy_D'] = 0
        PlayerPower[i]['duration_energy_D_precent_base'] = 0
        PlayerPower[i]['duration_energy_D_precent_final'] = 0
        PlayerPower[i]['duration_energy_C'] = 0
        PlayerPower[i]['duration_energy_C_precent_base'] = 0
        PlayerPower[i]['duration_energy_C_precent_final'] = 0
        PlayerPower[i]['duration_energy_B'] = 0
        PlayerPower[i]['duration_energy_B_precent_base'] = 0
        PlayerPower[i]['duration_energy_B_precent_final'] = 0
        PlayerPower[i]['duration_energy_A'] = 0
        PlayerPower[i]['duration_energy_A_precent_base'] = 0
        PlayerPower[i]['duration_energy_A_precent_final'] = 0
        PlayerPower[i]['player_energy_duration'] = 0
        PlayerPower[i]['player_energy_flag'] = 1

        PlayerPower[i]['player_energy_match_D'] = 0
        PlayerPower[i]['player_energy_match_D_precent_base'] = 0
        PlayerPower[i]['player_energy_match_D_precent_final'] = 0
        PlayerPower[i]['player_energy_match_C'] = 0
        PlayerPower[i]['player_energy_match_C_precent_base'] = 0
        PlayerPower[i]['player_energy_match_C_precent_final'] = 0
        PlayerPower[i]['player_energy_match_B'] = 0
        PlayerPower[i]['player_energy_match_B_precent_base'] = 0
        PlayerPower[i]['player_energy_match_B_precent_final'] = 0
        PlayerPower[i]['player_energy_match_A'] = 0
        PlayerPower[i]['player_energy_match_A_precent_base'] = 0
        PlayerPower[i]['player_energy_match_A_precent_final'] = 0
        PlayerPower[i]['temp_energy_match_D'] = 0
        PlayerPower[i]['temp_energy_match_D_precent_base'] = 0
        PlayerPower[i]['temp_energy_match_D_precent_final'] = 0
        PlayerPower[i]['temp_energy_match_C'] = 0
        PlayerPower[i]['temp_energy_match_C_precent_base'] = 0
        PlayerPower[i]['temp_energy_match_C_precent_final'] = 0
        PlayerPower[i]['temp_energy_match_B'] = 0
        PlayerPower[i]['temp_energy_match_B_precent_base'] = 0
        PlayerPower[i]['temp_energy_match_B_precent_final'] = 0
        PlayerPower[i]['temp_energy_match_A'] = 0
        PlayerPower[i]['temp_energy_match_A_precent_base'] = 0
        PlayerPower[i]['temp_energy_match_A_precent_final'] = 0
        PlayerPower[i]['duration_energy_match_D'] = 0
        PlayerPower[i]['duration_energy_match_D_precent_base'] = 0
        PlayerPower[i]['duration_energy_match_D_precent_final'] = 0
        PlayerPower[i]['duration_energy_match_C'] = 0
        PlayerPower[i]['duration_energy_match_C_precent_base'] = 0
        PlayerPower[i]['duration_energy_match_C_precent_final'] = 0
        PlayerPower[i]['duration_energy_match_B'] = 0
        PlayerPower[i]['duration_energy_match_B_precent_base'] = 0
        PlayerPower[i]['duration_energy_match_B_precent_final'] = 0
        PlayerPower[i]['duration_energy_match_A'] = 0
        PlayerPower[i]['duration_energy_match_A_precent_base'] = 0
        PlayerPower[i]['duration_energy_match_A_precent_final'] = 0
        PlayerPower[i]['player_energy_match_duration'] = 0
        PlayerPower[i]['player_energy_match_flag'] = 1

        
  
    end
end



