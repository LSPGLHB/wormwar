require('shoot_init')
function stageOne (keys)
    local caster	= keys.caster
	local ability	= keys.ability
    local modifierStageName	= keys.modifier_stage_a_name
	local numSpirits	= keys.spirit_count

    local particleName = "particles/units/heroes/hero_phoenix/phoenix_fire_spirits.vpcf"

	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( pfx, 1, Vector( numSpirits, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 6, Vector( numSpirits, 0, 0 ) )
	for i=1, numSpirits do
		ParticleManager:SetParticleControl( pfx, 8+i, Vector( 1, 0, 0 ) )
	end


	caster.fire_spirits_numSpirits	= numSpirits
	caster.fire_spirits_pfx			= pfx

	caster:SetModifierStackCount( modifierStageName, ability, numSpirits )

    local ability_b_name	= keys.ability_b_name
	local ability_a_name	= ability:GetAbilityName()
	caster:SwapAbilities( ability_a_name, ability_b_name, false, true )


end

function LaunchFire(keys)
    local caster	= keys.caster
	local ability	= keys.ability
	local modifierName	= keys.modifier_stage_a_name
	local skillPoint = ability:GetCursorPosition()
	local casterPoint = caster:GetAbsOrigin()
	--local casterDirection = caster:GetForwardVector()
	local shoot_speed = ability:GetLevelSpecialValueFor("stage_speed", ability:GetLevel() - 1)
	local speed = shoot_speed
	local distance = (skillPoint - casterPoint ):Length2D()
	local sDirection = (skillPoint - casterPoint ):Normalized() 
	local ability_a_name = caster:FindAbilityByName( keys.ability_a_name )

	local currentStack	= caster:GetModifierStackCount( modifierName, ability_a_name )
	currentStack = currentStack - 1
	
	caster:SetModifierStackCount( modifierName, ability_a_name, currentStack )

	local position = caster:GetAbsOrigin()
	local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
	shoot:SetOwner(caster)
	shoot.power_lv = 0
	shoot.power_flag = 0
	moveShoot(keys, shoot, max_distance, direction, speed, nil, shootHitCallBack, nil)

	-- Update the particle FX
	local pfx = caster.fire_spirits_pfx
	ParticleManager:SetParticleControl( pfx, 1, Vector( currentStack, 0, 0 ) )
	for i=1, caster.fire_spirits_numSpirits do
		local radius = 0
		if i <= currentStack then
			radius = 1
		end

		ParticleManager:SetParticleControl( pfx, 8+i, Vector( radius, 0, 0 ) )
	end

	-- Remove the stack modifier if all the spirits has been launched.
	if currentStack == 0 then
		caster:RemoveModifierByName( modifierName )
	end
    
end

function LevelUpAbility(keys)
    local caster = keys.caster
	local this_ability = keys.ability
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_b_name = keys.ability_b_name
	local ability_handle = caster:FindAbilityByName(ability_b_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function initStage(keys)
    local caster	= keys.caster
	local ability	= keys.ability


	local pfx = caster.fire_spirits_pfx
	ParticleManager:DestroyParticle( pfx, false )

	-- Swap main ability
	local ability_a_name	= ability:GetAbilityName()
	local ability_b_name	= keys.ability_b_name
	caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
end


function shootHitCallBack(keys,shoot,particleID)
	local ability = keys.ability
	local damage = getApplyDamageValue(keys,shoot)
	for i = 1, #shoot.hitUnits  do
		local unit = shoot.hitUnits[1]
		ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})	
	end
	if particleID ~= nil then
		ParticleManager:DestroyParticle(particleID, true)
	end
	shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit,keys.particles_hit_dur)
end
--[[
function power_charge( keys )
	local ability = keys.ability
	
	-- Fail check
	if not ability.power_charge_percent then
		ability.power_charge_percent = 0.0
	end
	ability.power_charge_percent = ability.power_charge_percent + 0.1

end]]