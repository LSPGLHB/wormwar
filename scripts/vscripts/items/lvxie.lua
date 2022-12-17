require('items_power')

function modifier_item_lvxie_on_created(keys)
    print("onCreated")
    local caster = keys.caster
    local ability = keys.ability
    local item_bonus_damage = ability:GetSpecialValueFor( "bonus_damage")
    local item_bonus_shoot_speed = ability:GetSpecialValueFor( "bonus_shoot_speed")

    local ITEM_DAMAGE = "item_damage"
    local ITEM_SHOOT_SPEED = "item_shoot_speed"

    setShootPower(caster,ITEM_DAMAGE,true,item_bonus_damage)
    setShootPower(caster,ITEM_SHOOT_SPEED,true,item_bonus_shoot_speed)


 
end

function modifier_item_lvxie_on_destroy(keys)

    print("onDestroy")
    local caster = keys.caster
    local ability = keys.ability
    local item_bonus_damage = ability:GetSpecialValueFor( "bonus_damage")
    local item_bonus_shoot_speed = ability:GetSpecialValueFor( "bonus_shoot_speed")

    local ITEM_DAMAGE = "item_damage"
    local ITEM_SHOOT_SPEED = "item_shoot_speed"

    setShootPower(caster,ITEM_DAMAGE,false,item_bonus_damage)
    setShootPower(caster,ITEM_SHOOT_SPEED,false,item_bonus_shoot_speed)


end


