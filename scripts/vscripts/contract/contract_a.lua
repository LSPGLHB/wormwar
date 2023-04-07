require('contract_power')
function modifier_contract_contract_a_on_created(keys)
    print("onCreated_contract_a")
 
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local contract_vision = ability:GetSpecialValueFor( "contract_vision")
    local contract_speed = ability:GetSpecialValueFor( "contract_speed")
    local contract_health_precent_final = ability:GetSpecialValueFor( "contract_health_precent_final")

    setContractPower(playerID, "contract_vision", true, contract_vision)
    setContractPower(playerID, "contract_speed", true, contract_speed)
    setContractPower(playerID, "contract_health_precent_final", true, contract_health_precent_final)
    --local tempMoveSpeed = hHero:GetBaseMoveSpeed()
    --hHero:SetBaseMoveSpeed(tempMoveSpeed+contract_speed_bouns)--可行有效

    local abilityVision = "ability_vision_control"
    local modifierVisionBuff = "modifier_vision_buff"  
    local modifierVisionDebuff = "modifier_vision_debuff"
    local modifierVisionValue =  ContractPower[playerID]['contract_vision'] / 100 * ContractPower[playerID]['contract_vision_flag']
    addContractBuffByAbilityAndModifier(keys, abilityVision, modifierVisionBuff, modifierVisionDebuff, modifierVisionValue)

    local abilitySpeed = "ability_speed_control"
    local modifierSpeedBuff = "modifier_speed_buff" 
    local modifierSpeedDebuff = "modifier_speed_debuff"
    local modifierSpeedValue = ContractPower[playerID]['contract_speed'] * ContractPower[playerID]['contract_speed_flag']
    addContractBuffByAbilityAndModifier(keys, abilitySpeed, modifierSpeedBuff, modifierSpeedDebuff, modifierSpeedValue)



    local abilityHealth = "ability_health_control"
    local modifierHealthBuff= "modifier_health_buff"  
    local modifierHealthDebuff= "modifier_health_debuff"  
    local heroHealth = caster:GetHealth()
    local modifierHealthValue = heroHealth * ContractPower[playerID]['contract_health_precent_final'] / 100 
    addContractBuffByAbilityAndModifier(keys, abilityHealth, modifierHealthBuff, modifierHealthDebuff, modifierHealthValue)

      


end

function modifier_contract_contract_a_on_destroy(keys)
    print("onDestroy_contract_a")
    
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local contract_vision_bonus = ability:GetSpecialValueFor( "contract_vision")
    local contract_speed_bouns = ability:GetSpecialValueFor( "contract_speed")
    local contract_health_precent_final = ability:GetSpecialValueFor( "contract_health_precent_final")

    setContractPower(playerID, "contract_vision", false, contract_vision_bonus)
    setContractPower(playerID, "contract_speed", false, contract_speed_bouns)
    setContractPower(playerID, "contract_health_precent_final", false, contract_health_precent_final)


    local abilityVision = "ability_vision_control"
    local modifierVisionBuff = "modifier_vision_buff"  
    local modifierVisionDebuff = "modifier_vision_debuff"
    removeContractBuffByAbilityAndModifier(keys, abilityVision, modifierVisionBuff, modifierVisionDebuff) 

    local abilitySpeed = "ability_speed_control"
    local modifierSpeedBuff = "modifier_speed_buff" 
    local modifierSpeedDebuff = "modifier_speed_debuff"
    removeContractBuffByAbilityAndModifier(keys, abilitySpeed, modifierSpeedBuff, modifierSpeedDebuff) 


    local abilityHealth = "ability_health_control"
    local modifierHealthBuff= "modifier_health_buff"  
    local modifierHealthDebuff= "modifier_health_debuff"
    removeContractBuffByAbilityAndModifier(keys, abilityHealth, modifierHealthBuff, modifierHealthDebuff) 
end


