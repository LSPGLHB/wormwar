require('contract_power')
function modifier_contract_contract_b_on_created(keys)
    print("onCreated_contract_b")
 
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()


    local contract_health_precent_final = ability:GetSpecialValueFor( "contract_health_precent_final")
    local contract_speed_flag = ability:GetSpecialValueFor( "contract_speed_flag")



    setContractPower(playerID, "contract_health_precent_final", true, contract_health_precent_final)
    setContractPower(playerID, "contract_speed_flag", true, contract_speed_flag)


    local abilityHealth = "ability_health_control"
    local modifierHealthBuff= "modifier_health_buff"  
    local modifierHealthDebuff= "modifier_health_debuff"  
    local heroHealth = caster:GetHealth()
    local modifierHealthValue = heroHealth * ContractPower[playerID]['contract_health_precent_final'] / 100 
    addContractBuffByAbilityAndModifier(keys, abilityHealth, modifierHealthBuff, modifierHealthDebuff, modifierHealthValue)


    local abilitySpeed = "ability_speed_control"
    local modifierSpeedBuff= "modifier_speed_buff"  
    local modifierSpeedDebuff= "modifier_speed_debuff" 
    local modifierSpeedValue = ContractPower[playerID]['contract_speed'] * ContractPower[playerID]['contract_speed_flag']
    addContractBuffByAbilityAndModifier(keys, abilitySpeed, modifierSpeedBuff, modifierSpeedDebuff, modifierSpeedValue)


end

function modifier_contract_contract_b_on_destroy(keys)

    print("onDestroy_contract_b")

    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
    local contract_health_precent_final = ability:GetSpecialValueFor( "contract_health_precent_final")
    local contract_speed_flag = ability:GetSpecialValueFor( "contract_speed_flag")

    setContractPower(playerID, "contract_health_precent_final", false, contract_health_precent_final)
    setContractPower(playerID, "contract_speed_flag", false, contract_speed_flag)



    local abilityHealth = "ability_health_control"
    local modifierHealthBuff= "modifier_health_buff"  
    local modifierHealthDebuff= "modifier_health_debuff"
    removeContractBuffByAbilityAndModifier(keys, abilityHealth, modifierHealthBuff, modifierHealthDebuff) 

    local abilitySpeed = "ability_speed_control"
    local modifierSpeedBuff= "modifier_speed_buff"  
    local modifierSpeedDebuff= "modifier_speed_debuff" 
    removeContractBuffByAbilityAndModifier(keys, abilitySpeed, modifierSpeedBuff, modifierSpeedDebuff) 

end


