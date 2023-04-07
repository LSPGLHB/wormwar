function initContractPower()
    ContractPower={}
    for i = 0, 9 do
        ContractPower[i] = {} --每个玩家数据包
        ContractPower[i]['contract_vision'] = 0
        ContractPower[i]['contract_vision_flag'] = 1
        ContractPower[i]['contract_speed'] = 0
        ContractPower[i]['contract_speed_flag'] = 1
        ContractPower[i]['contract_ability_speed'] = 0
        ContractPower[i]['contract_damage'] = 0
        ContractPower[i]['contract_health'] = 0
        ContractPower[i]['contract_health_precent_final'] = 0
        ContractPower[i]['contract_health_flag'] = 1


    end
end

function addContractBuffByAbilityAndModifier(keys, abilityName, modifierNameBuff, modifierNameDebuff, modifierStackCount)
    local caster = keys.caster
    --local playerID = caster:GetPlayerID()
    --local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
   -- local player = PlayerResource:GetPlayer(playerID)
    local modifierNameAdd
    local modifierNameRemove

    
    
    if (modifierStackCount == 0) then
        removeContractBuffByAbilityAndModifier(keys, abilityName, modifierNameBuff,modifierNameDebuff)
    else
        if (not caster:HasAbility(abilityName)) then
            caster:AddAbility(abilityName):SetLevel(1)
        end

        if (modifierStackCount > 0) then
            modifierNameAdd = modifierNameBuff
            modifierNameRemove = modifierNameDebuff
        else
            modifierNameAdd = modifierNameDebuff
            modifierNameRemove = modifierNameBuff
            modifierStackCount = modifierStackCount * -1
        end
        caster:RemoveModifierByName(modifierNameRemove)
        caster:SetModifierStackCount( modifierNameAdd, caster, modifierStackCount )
    end
   
end

function removeContractBuffByAbilityAndModifier(keys, abilityName, modifierNameBuff,modifierNameDebuff)
    local caster = keys.caster
    --local playerID = caster:GetPlayerID()
    --local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    --local player = PlayerResource:GetPlayer(playerID)
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







function setContractPower(playerID, powerName, isAdd, value)
    if( not isAdd ) then
        value = value * -1
    end
    ContractPower[playerID][powerName] = ContractPower[playerID][powerName] + value
end




function getContractPower(playerID, powerName)

    local value = ContractPower[playerID][powerName]


    return value
end



