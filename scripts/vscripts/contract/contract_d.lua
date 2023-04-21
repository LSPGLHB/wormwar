require('player_power')
function modifier_contract_contract_d_on_created(keys)
    print("onCreated_contract_d")
    refreshContractBuff(keys,true)
end

function modifier_contract_contract_d_on_destroy(keys)

    print("onDestroy_contract_d")

    refreshContractBuff(keys,false)

end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
    local contract_control_precent_final = ability:GetSpecialValueFor( "contract_control_precent_final")
    local contract_speed_precent_final = ability:GetSpecialValueFor( "contract_speed_precent_final")
    local contract_damage_flag = ability:GetSpecialValueFor( "contract_damage_flag")

    if (not flag) then
        contract_damage_flag = 1
    end

    setPlayerPower(playerID, "player_control_precent_final", flag, contract_control_precent_final)
    setPlayerPower(playerID, "player_speed_precent_final", flag, contract_speed_precent_final) 
    setPlayerPowerFlag(playerID, "player_damage_flag", contract_damage_flag)

    setPlayerBuffByNameAndBValue(caster,"speed",GameRules.playerBaseSpeed)
end


