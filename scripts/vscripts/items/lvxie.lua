require('player_power')

function modifier_item_lvxie_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_lvxie_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)

    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_health = ability:GetSpecialValueFor( "item_health")
    local item_speed = ability:GetSpecialValueFor( "item_speed")
    local item_speed_precent_final = ability:GetSpecialValueFor( "item_speed_precent_final")
    
    
    
    local item_mana = ability:GetSpecialValueFor( "item_mana")
    local item_mana_regen = ability:GetSpecialValueFor( "item_mana_regen")
    local item_ability_speed_C = ability:GetSpecialValueFor( "item_ability_speed_C")
    local item_ability_speed_C_precent_base = ability:GetSpecialValueFor( "item_ability_speed_C_precent_base")
    local item_range_C = ability:GetSpecialValueFor( "item_range_C")
    local item_range_C_precent_base = ability:GetSpecialValueFor( "item_range_C_precent_base")
    local item_damage_C = ability:GetSpecialValueFor( "item_damage_C")
    local item_damage_C_precent_base = ability:GetSpecialValueFor( "item_damage_C_precent_base")
    local item_control_C_precent_base = ability:GetSpecialValueFor( "item_control_C_precent_base")
    local item_energy_C_precent_base = ability:GetSpecialValueFor( "item_energy_C_precent_base")
    local item_mana_cost_C_precent = ability:GetSpecialValueFor( "item_mana_cost_C_precent")
    local item_damage_match_C_precent_base = ability:GetSpecialValueFor( "item_damage_match_C_precent_base")
    local item_control_match_C_precent_base = ability:GetSpecialValueFor( "item_control_match_C_precent_base")
    local item_energy_match_C = ability:GetSpecialValueFor( "item_energy_match_C")


    local duration_speed_precent_final = ability:GetSpecialValueFor( "duration_speed_precent_final") 
    local item_speed_duration = ability:GetSpecialValueFor( "item_speed_duration") 
    local duration_vision = ability:GetSpecialValueFor( "duration_vision") 
    local item_vision_duration = ability:GetSpecialValueFor( "item_vision_duration") 
    local duration_health = ability:GetSpecialValueFor( "duration_health") 
    local item_health_duration = ability:GetSpecialValueFor( "item_health_duration") 
    local duration_mana = ability:GetSpecialValueFor( "duration_mana") 
    local item_mana_duration = ability:GetSpecialValueFor( "item_mana_duration") 
    local duration_mana_regen = ability:GetSpecialValueFor( "duration_mana_regen") 
    local item_mana_regen_duration = ability:GetSpecialValueFor( "item_mana_regen_duration") 


    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_speed", flag, item_speed)
    setPlayerPower(playerID, "player_speed_precent_final", flag, item_speed_precent_final)
    setPlayerPower(playerID, "player_mana", flag, item_mana)
    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)

    
    
    setPlayerPower(playerID, "player_ability_speed_C", flag, item_ability_speed_C)
    setPlayerPower(playerID, "player_ability_speed_C_precent_base", flag, item_ability_speed_C_precent_base)
    setPlayerPower(playerID, "player_range_C", flag, item_range_C)
    setPlayerPower(playerID, "player_range_C_precent_base", flag, item_range_C_precent_base)
    setPlayerPower(playerID, "player_damage_C", flag, item_damage_C)
    setPlayerPower(playerID, "player_damage_C_precent_base", flag, item_damage_C_precent_base)
    setPlayerPower(playerID, "player_control_C_precent_base", flag, item_control_C_precent_base)
    setPlayerPower(playerID, "player_energy_C_precent_base", flag, item_energy_C_precent_base)
    setPlayerPower(playerID, "player_mana_cost_C_precent", flag, item_mana_cost_C_precent)
    setPlayerPower(playerID, "player_damage_match_C_precent_base", flag, item_damage_match_C_precent_base)
    setPlayerPower(playerID, "player_control_match_C_precent_base", flag, item_control_match_C_precent_base)
    setPlayerPower(playerID, "player_energy_match_C", flag, item_energy_match_C)


    setPlayerPower(playerID, "duration_speed_precent_final", flag, duration_speed_precent_final)
    setPlayerPower(playerID, "player_speed_duration", flag, item_speed_duration)
    setPlayerPower(playerID, "duration_vision", flag, duration_vision)
    setPlayerPower(playerID, "player_vision_duration", flag, item_vision_duration)
    setPlayerPower(playerID, "duration_health", flag, duration_health)
    setPlayerPower(playerID, "player_health_duration", flag, item_health_duration)
    setPlayerPower(playerID, "duration_mana", flag, duration_mana)
    setPlayerPower(playerID, "player_mana_duration", flag, item_mana_duration)
    setPlayerPower(playerID, "duration_mana_regen", flag, duration_mana_regen)
    setPlayerPower(playerID, "player_mana_regen_duration", flag, item_mana_regen_duration)


    setPlayerBuffByNameAndBValue(caster,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(caster,"speed",GameRules.playerBaseSpeed)
    setPlayerBuffByNameAndBValue(caster,"mana",GameRules.playerBaseMana)
    setPlayerBuffByNameAndBValue(caster,"mana_regen",GameRules.playerManaRegen)










end


