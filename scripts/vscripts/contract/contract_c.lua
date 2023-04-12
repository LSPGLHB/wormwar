require('player_power')
function modifier_contract_contract_c_on_created(keys)
    print("onCreated_contract_c")
    refreshContractBuff(keys,true)
end

function modifier_contract_contract_c_on_destroy(keys)

    print("onDestroy_contract_c")

    refreshContractBuff(keys,false)

end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    

    local contract_energy_C_precent_base = ability:GetSpecialValueFor( "contract_energy_C_precent_base")
    local contract_energy_B_precent_base = ability:GetSpecialValueFor( "contract_energy_B_precent_base")
    local contract_energy_A_precent_base = ability:GetSpecialValueFor( "contract_energy_A_precent_base")
    local contract_vision_flag = ability:GetSpecialValueFor( "contract_vision_flag")
    local contract_damage_flag = ability:GetSpecialValueFor( "contract_damage_flag")
    local contract_control_flag = ability:GetSpecialValueFor( "contract_control_flag")

    if (not flag) then
        contract_vision_flag = 1
        contract_damage_flag = 1
        contract_control_flag = 1
    end

    setPlayerPower(playerID, "player_energy_C_precent_base", flag, contract_energy_C_precent_base)
    setPlayerPower(playerID, "player_energy_B_precent_base", flag, contract_energy_B_precent_base)
    setPlayerPower(playerID, "player_energy_A_precent_base", flag, contract_energy_A_precent_base)
    
    setPlayerPowerFlag(playerID, "player_vision_flag", contract_vision_flag) --buff能力
    setPlayerPowerFlag(playerID, "player_damage_flag", contract_damage_flag)
    setPlayerPowerFlag(playerID, "player_control_flag", contract_control_flag)

    setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision)
end


