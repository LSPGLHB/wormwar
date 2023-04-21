require('player_power')

function initVision(keys)
    print("onCreated_player_temp_buff_vision")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local buffName = "vision"
    local baseValue = caster:GetCurrentVisionRange()
    setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
end

function initSpeed(keys)
    print("onCreated_player_temp_buff_speed")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local buffName = "speed"  
    local baseValue = caster:GetIdealSpeed()
    setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
end

function initHealth(keys)
    print("onCreated_player_temp_buff_health")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local buffName = "health"  
    local baseValue = caster:GetHealth()
    setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
end

function initMana(keys)
    print("onCreated_player_temp_buff_mana")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local buffName = "mana"  
    local baseValue = caster:GetMana()
    setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
end

function initManaRegen(keys)
    print("onCreated_player_temp_buff_mana_regen")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local buffName = "mana_regen"  
    local baseValue = caster:GetManaRegen()
    setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
end