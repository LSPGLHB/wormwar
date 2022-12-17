function setShootPower(caster, powerName, isAdd, value)

    initShootPower(caster)


    if( not isAdd ) then
        value = value * -1
    end

    if(powerName == "item_damage") then       
        caster.item_bonus_damage = caster.item_bonus_damage + value 
    end
    if(powerName == "item_shoot_speed") then       
        caster.item_bonus_shoot_speed = caster.item_bonus_shoot_speed + value 
    end
    
    

end


function getShootPower(caster, powerName)

    local value
    if(powerName == "item_damage") then       
        value = caster.item_bonus_damage
    end
    if(powerName == "item_shoot_speed") then    
        value = caster.item_bonus_shoot_speed
    end
    return value
end


function initShootPower(caster)

    if caster.item_bonus_damage == nil then
        caster.item_bonus_damage = 0
    end

    if caster.item_bonus_shoot_speed == nil then
        caster.item_bonus_shoot_speed = 0
    end


end