function stageOne (keys)
    local caster	= keys.caster
	local ability	= keys.ability
    local modifierStageName	= keys.modifier_stage_a_name
	local numSpirits	= keys.spirit_count

    local particleName = "particles/units/heroes/hero_phoenix/phoenix_fire_spirits.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( pfx, 1, Vector( numSpirits, 0, 0 ) )

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

	local ability_a_name = caster:FindAbilityByName( keys.ability_a_name )

	local currentStack	= caster:GetModifierStackCount( modifierName, ability_a_name )
	currentStack = currentStack - 1
	
	caster:SetModifierStackCount( modifierName, ability_a_name, currentStack )

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