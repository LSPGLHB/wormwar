function setShootPower(caster, powerName, isAdd, value)


    if( not isAdd ) then
        value = value * -1
    end
    --测试内容
    if(powerName == "item_damage") then    
        if caster.item_bonus_damage == nil then
            caster.item_bonus_damage = value 
        else
            caster.item_bonus_damage = caster.item_bonus_damage + value 
        end
    end
    --测试内容
    if(powerName == "item_shoot_speed") then  
        if caster.item_bonus_shoot_speed == nil then
            caster.item_bonus_shoot_speed = value
        else
            caster.item_bonus_shoot_speed = caster.item_bonus_shoot_speed + value 
        end
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


