function shootSpeedUp(keys)
    local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
    local buff_modifier = "modifier_shoot_speed_up_buff"
   	
   --[[ if target.stacks == nil then
		target.stacks = 0
	end]]

    local previous_stacks
	if caster:HasModifier(buff_modifier) then
		previous_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	else
		previous_stacks = 1
	end

    local new_stacks = previous_stacks + 1
    caster:SetModifierStackCount(buff_modifier, ability, new_stacks )




end

function shootSpeedDown(keys)
	local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
    local buff_modifier = "modifier_shoot_speed_up_buff"
   	
   --[[ if target.stacks == nil then
		target.stacks = 0
	end]]

    local previous_stacks
	if caster:HasModifier(buff_modifier) then
		previous_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	else
		previous_stacks = 1
	end

    local new_stacks = previous_stacks - 1
    caster:SetModifierStackCount(buff_modifier, ability, new_stacks )

end

function upGrade(keys)
    local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
    local buff_modifier = "modifier_shoot_speed_up_buff"
    
	local speed_up_per_stack = ability:GetLevelSpecialValueFor( "speed_up_per_stack", ( ability:GetLevel() - 1 ) )
	caster.speed_up_per_stack = speed_up_per_stack
	print("speed_up_per_stack:==="..speed_up_per_stack)
    previous_stacks = caster:SetModifierStackCount(buff_modifier, ability, 1)

end



