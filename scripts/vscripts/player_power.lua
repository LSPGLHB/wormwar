function setPlayerBuffByNameAndBValue(keys,buffName,baseValue)
    local modifierName = "player_"..buffName
    local abilityName = "ability_"..buffName.."_control"
    local modifierNameBuff = "modifier_"..buffName.."_buff"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff"
    local modifierStackCount =  getPlayerPowerValueByName(keys, modifierName, baseValue)
    setPlayerBuffByAbilityAndModifier(keys, abilityName, modifierNameBuff, modifierNameDebuff, modifierStackCount)
end

function setPlayerBuffByAbilityAndModifier(keys, abilityName, modifierNameBuff, modifierNameDebuff, modifierStackCount)
    local caster = keys.caster
    --local playerID = caster:GetPlayerID()
    --local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
   -- local player = PlayerResource:GetPlayer(playerID)
    local modifierNameAdd
    local modifierNameRemove

    removePlayerBuffByAbilityAndModifier(keys, abilityName, modifierNameBuff,modifierNameDebuff)

    if (modifierStackCount ~= 0) then
       
        caster:AddAbility(abilityName):SetLevel(1)

        if (modifierStackCount > 0) then
            modifierNameAdd = modifierNameBuff
            modifierNameRemove = modifierNameDebuff
        else
            modifierNameAdd = modifierNameDebuff
            modifierNameRemove = modifierNameBuff
            modifierStackCount = modifierStackCount * -1
        end

        caster:RemoveModifierByName(modifierNameRemove)

        caster:SetModifierStackCount(modifierNameAdd, caster, modifierStackCount)
    end
   
end

function removePlayerBuffByAbilityAndModifier(keys, abilityName, modifierNameBuff,modifierNameDebuff)
    local caster = keys.caster
    if (caster:HasAbility(abilityName)) then
        caster:RemoveAbility(abilityName)
    end
    if(caster:HasModifier(modifierNameBuff)) then
        caster:RemoveModifierByName(modifierNameBuff)
    end
    if(caster:HasModifier(modifierNameDebuff)) then
        caster:RemoveModifierByName(modifierNameDebuff)
    end
end

function setPlayerPower(playerID, powerName, isAdd, value)
    print("setPlayerPower")
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
function getPlayerPowerValueByName(keys, powerName, playerBaseValue)
    local caster = keys.caster
    local playerID = caster:GetPlayerID()

    print("getPlayerPowerValueByName",playerID,powerName,playerBaseValue)
    local precentBaseBuff = powerName .. "_precent_base"
    local precentFinalBuff = powerName .. "_precent_final"

    local powerValue = PlayerPower[playerID][powerName]
    local precentBaseValue = PlayerPower[playerID][precentBaseBuff] / 100
    local precentFinalValue = PlayerPower[playerID][precentFinalBuff] /100
    --print(powerValue,precentBaseValue,precentFinalValue)

    local stackCount = (playerBaseValue * (1 + precentBaseValue) + powerValue ) * (1 + precentFinalValue) - playerBaseValue
    print(powerName,"=stackCount=",stackCount)

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
        PlayerPower[i]['duration_vision'] = 0
        PlayerPower[i]['duration_vision_precent_base'] = 0
        PlayerPower[i]['duration_vision_precent_final'] = 0
        PlayerPower[i]['player_vision_duration'] = 0
        PlayerPower[i]['player_vision_flag'] = 1

        PlayerPower[i]['player_speed'] = 0
        PlayerPower[i]['player_speed_precent_base'] = 0
        PlayerPower[i]['player_speed_precent_final'] = 0
        PlayerPower[i]['duration_speed'] = 0
        PlayerPower[i]['duration_speed_precent_base'] = 0
        PlayerPower[i]['duration_speed_precent_final'] = 0
        PlayerPower[i]['player_speed_duration'] = 0
        PlayerPower[i]['player_speed_flag'] = 1
        

        PlayerPower[i]['player_health'] = 0     
        PlayerPower[i]['player_health_precent_base'] = 0
        PlayerPower[i]['player_health_precent_final'] = 0
        PlayerPower[i]['duration_health'] = 0     
        PlayerPower[i]['duration_health_precent_base'] = 0
        PlayerPower[i]['duration_health_precent_final'] = 0
        PlayerPower[i]['player_health_duration'] = 0
        PlayerPower[i]['player_health_flag'] = 1

        PlayerPower[i]['player_mana'] = 0     
        PlayerPower[i]['player_mana_precent_base'] = 0
        PlayerPower[i]['player_mana_precent_final'] = 0
        PlayerPower[i]['duration_mana'] = 0     
        PlayerPower[i]['duration_mana_precent_base'] = 0
        PlayerPower[i]['duration_mana_precent_final'] = 0
        PlayerPower[i]['player_mana_duration'] = 0
        PlayerPower[i]['player_mana_flag'] = 1

        PlayerPower[i]['player_mana_regen'] = 0     
        PlayerPower[i]['player_mana_regen_precent_base'] = 0
        PlayerPower[i]['player_mana_regen_precent_final'] = 0
        PlayerPower[i]['duration_mana_regen'] = 0     
        PlayerPower[i]['duration_mana_regen_precent_base'] = 0
        PlayerPower[i]['duration_mana_regen_precent_final'] = 0
        PlayerPower[i]['player_mana_regen_duration'] = 0
        PlayerPower[i]['player_mana_regen_flag'] = 1


        --技能能力
        PlayerPower[i]['player_ability_speed_C'] = 0
        PlayerPower[i]['player_ability_speed_C_precent_base'] = 0
        PlayerPower[i]['player_ability_speed_C_precent_final'] = 0
        PlayerPower[i]['player_ability_speed_B'] = 0
        PlayerPower[i]['player_ability_speed_B_precent_base'] = 0
        PlayerPower[i]['player_ability_speed_B_precent_final'] = 0
        PlayerPower[i]['player_ability_speed_A'] = 0
        PlayerPower[i]['player_ability_speed_A_precent_base'] = 0
        PlayerPower[i]['player_ability_speed_A_precent_final'] = 0
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

        PlayerPower[i]['player_range_C'] = 0
        PlayerPower[i]['player_range_C_precent_base'] = 0
        PlayerPower[i]['player_range_C_precent_final'] = 0
        PlayerPower[i]['player_range_B'] = 0
        PlayerPower[i]['player_range_B_precent_base'] = 0
        PlayerPower[i]['player_range_B_precent_final'] = 0
        PlayerPower[i]['player_range_A'] = 0
        PlayerPower[i]['player_range_A_precent_base'] = 0
        PlayerPower[i]['player_range_A_precent_final'] = 0
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

        PlayerPower[i]['player_mana_cost_C'] = 0
        PlayerPower[i]['player_mana_cost_C_precent'] = 0
        PlayerPower[i]['player_mana_cost_B'] = 0
        PlayerPower[i]['player_mana_cost_B_precent'] = 0
        PlayerPower[i]['player_mana_cost_A'] = 0
        PlayerPower[i]['player_mana_cost_A_precent'] = 0
        PlayerPower[i]['duration_mana_cost_C'] = 0
        PlayerPower[i]['duration_mana_cost_C_precent'] = 0
        PlayerPower[i]['duration_mana_cost_B'] = 0
        PlayerPower[i]['duration_mana_cost_B_precent'] = 0
        PlayerPower[i]['duration_mana_cost_A'] = 0
        PlayerPower[i]['duration_mana_cost_A_precent'] = 0
        PlayerPower[i]['player_mana_cost_duration'] = 0

        PlayerPower[i]['player_damage_C'] = 0
        PlayerPower[i]['player_damage_C_precent_base'] = 0
        PlayerPower[i]['player_damage_C_precent_final'] = 0
        PlayerPower[i]['player_damage_B'] = 0
        PlayerPower[i]['player_damage_B_precent_base'] = 0
        PlayerPower[i]['player_damage_B_precent_final'] = 0
        PlayerPower[i]['player_damage_A'] = 0
        PlayerPower[i]['player_damage_A_precent_base'] = 0
        PlayerPower[i]['player_damage_A_precent_final'] = 0
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

        PlayerPower[i]['player_damage_match_C'] = 0
        PlayerPower[i]['player_damage_match_C_precent_base'] = 0
        PlayerPower[i]['player_damage_match_C_precent_final'] = 0
        PlayerPower[i]['player_damage_match_B'] = 0
        PlayerPower[i]['player_damage_match_B_precent_base'] = 0
        PlayerPower[i]['player_damage_match_B_precent_final'] = 0
        PlayerPower[i]['player_damage_match_A'] = 0
        PlayerPower[i]['player_damage_match_A_precent_base'] = 0
        PlayerPower[i]['player_damage_match_A_precent_final'] = 0
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

        PlayerPower[i]['player_control_C'] = 0
        PlayerPower[i]['player_control_C_precent_base'] = 0
        PlayerPower[i]['player_control_C_precent_final'] = 0
        PlayerPower[i]['player_control_B'] = 0
        PlayerPower[i]['player_control_B_precent_base'] = 0
        PlayerPower[i]['player_control_B_precent_final'] = 0
        PlayerPower[i]['player_control_A'] = 0
        PlayerPower[i]['player_control_A_precent_base'] = 0
        PlayerPower[i]['player_control_A_precent_final'] = 0
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

        PlayerPower[i]['player_control_match_C'] = 0
        PlayerPower[i]['player_control_match_C_precent_base'] = 0
        PlayerPower[i]['player_control_match_C_precent_final'] = 0
        PlayerPower[i]['player_control_match_B'] = 0
        PlayerPower[i]['player_control_match_B_precent_base'] = 0
        PlayerPower[i]['player_control_match_B_precent_final'] = 0
        PlayerPower[i]['player_control_match_A'] = 0
        PlayerPower[i]['player_control_match_A_precent_base'] = 0
        PlayerPower[i]['player_control_match_A_precent_final'] = 0
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
        
        PlayerPower[i]['player_energy_C'] = 0
        PlayerPower[i]['player_energy_C_precent_base'] = 0
        PlayerPower[i]['player_energy_C_precent_final'] = 0
        PlayerPower[i]['player_energy_B'] = 0
        PlayerPower[i]['player_energy_B_precent_base'] = 0
        PlayerPower[i]['player_energy_B_precent_final'] = 0
        PlayerPower[i]['player_energy_A'] = 0
        PlayerPower[i]['player_energy_A_precent_base'] = 0
        PlayerPower[i]['player_energy_A_precent_final'] = 0
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

        PlayerPower[i]['player_energy_match_C'] = 0
        PlayerPower[i]['player_energy_match_C_precent_base'] = 0
        PlayerPower[i]['player_energy_match_C_precent_final'] = 0
        PlayerPower[i]['player_energy_match_B'] = 0
        PlayerPower[i]['player_energy_match_B_precent_base'] = 0
        PlayerPower[i]['player_energy_match_B_precent_final'] = 0
        PlayerPower[i]['player_energy_match_A'] = 0
        PlayerPower[i]['player_energy_match_A_precent_base'] = 0
        PlayerPower[i]['player_energy_match_A_precent_final'] = 0
        PlayerPower[i]['duration_energy_match_C'] = 0
        PlayerPower[i]['duration_energy_match_C_precent_base'] = 0
        PlayerPower[i]['duration_energy_match_C_precent_final'] = 0
        PlayerPower[i]['duration_energy_match_B'] = 0
        PlayerPower[i]['duration_energy_match_B_precent_base'] = 0
        PlayerPower[i]['duration_energy_match_B_precent_final'] = 0
        PlayerPower[i]['duration_energy_match_A'] = 0
        PlayerPower[i]['duration_energy_match_A_precent_base'] = 0
        PlayerPower[i]['duration_energy_match_A_precent_final'] = 0
        PlayerPower[i]['player_energy_match_duration'] = 1
        PlayerPower[i]['player_energy_match_flag'] = 1

        
  
    end
end



