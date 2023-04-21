require('player_power')
function modifier_contract_contract_e_on_created(keys)
    print("onCreated_contract_e")
    refreshContractBuff(keys,true)
end

function modifier_contract_contract_e_on_destroy(keys)

    print("onDestroy_contract_e")

    refreshContractBuff(keys,false)

end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
    local contract_vision = ability:GetSpecialValueFor( "contract_vision")
    local contract_health_precent_final = ability:GetSpecialValueFor( "contract_health_precent_final")
    local contract_speed = ability:GetSpecialValueFor( "contract_speed")
    local contract_mana_precent_final = ability:GetSpecialValueFor( "contract_mana_precent_final")  
    local contract_range_precent_final = ability:GetSpecialValueFor( "contract_range_precent_final")
    local contract_damage_precent_final = ability:GetSpecialValueFor( "contract_damage_precent_final")
    local contract_control_precent_final = ability:GetSpecialValueFor( "contract_control_precent_final")


    setPlayerPower(playerID, "player_vision", flag, contract_vision)
    setPlayerPower(playerID, "player_health_precent_final", flag, contract_health_precent_final)
    setPlayerPower(playerID, "player_speed", flag, contract_speed)
    setPlayerPower(playerID, "player_mana_precent_final", flag, contract_mana_precent_final)
    
    setPlayerPower(playerID, "player_range_C_precent_final", flag, contract_range_precent_final)
    setPlayerPower(playerID, "player_range_B_precent_final", flag, contract_range_precent_final)
    setPlayerPower(playerID, "player_range_A_precent_final", flag, contract_range_precent_final)

    setPlayerPower(playerID, "player_damage_C_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "player_damage_B_precent_final", flag, contract_damage_precent_final)
    setPlayerPower(playerID, "player_damage_A_precent_final", flag, contract_damage_precent_final)

    setPlayerPower(playerID, "player_control_C_precent_final", flag, contract_control_precent_final)
    setPlayerPower(playerID, "player_control_B_precent_final", flag, contract_control_precent_final)
    setPlayerPower(playerID, "player_control_A_precent_final", flag, contract_control_precent_final)

    setPlayerBuffByNameAndBValue(caster,"vision",GameRules.playerBaseVision)
    setPlayerBuffByNameAndBValue(caster,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(caster,"speed",GameRules.playerBaseSpeed)
    setPlayerBuffByNameAndBValue(caster,"mana",GameRules.playerBaseMana)
end


