require('player_power')
function modifier_contract_contract_a_on_created(keys)
    print("onCreated_contract_a")
    refreshContractBuff(keys,true)
end

function modifier_contract_contract_a_on_destroy(keys)
    print("onDestroy_contract_a")   
    refreshContractBuff(keys,false)
end

function refreshContractBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local contract_vision = ability:GetSpecialValueFor( "contract_vision")
    local contract_speed = ability:GetSpecialValueFor( "contract_speed")
    local contract_health_precent_final = ability:GetSpecialValueFor( "contract_health_precent_final")

    setPlayerPower(playerID, "player_vision", flag, contract_vision)
    setPlayerPower(playerID, "player_speed", flag, contract_speed)
    setPlayerPower(playerID, "player_health_precent_final", flag, contract_health_precent_final)

    setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision)
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
end


