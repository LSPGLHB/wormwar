--LinkLuaModifier( "modifier_movespeed_cap", "modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function speedUp(keys)
    local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
    local buff_modifier = "modifier_speed_up_buff"



    local previous_stacks
	if caster:HasModifier(buff_modifier) then
		previous_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	else
		previous_stacks = 1
	end

    local new_stacks = previous_stacks + 1
    caster:SetModifierStackCount(buff_modifier, ability, new_stacks )


end

function upGrade(keys)
    local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
    local buff_modifier = "modifier_speed_up_buff"
--[[
    if caster:HasModifier("modifier_movespeed_cap") == false then
		caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", {})
	end
]]
    previous_stacks = caster:SetModifierStackCount(buff_modifier, ability, 1)

end

function speedDown(keys)
    local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
    local buff_modifier = "modifier_speed_up_buff"


    local previous_stacks
	if caster:HasModifier(buff_modifier) then
		previous_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	else
		previous_stacks = 1
	end

    local new_stacks = previous_stacks - 1
    caster:SetModifierStackCount(buff_modifier, ability, new_stacks )


end

function upGradeDown(keys)
    local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
    local buff_modifier = "modifier_speed_up_buff"
    

   -- previous_stacks = caster:SetModifierStackCount(buff_modifier, ability, 1)

end

