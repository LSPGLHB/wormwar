function stageOne (keys)
    local caster	= keys.caster
	local ability	= keys.ability
    local modifierStageName	= keys.modifier_stage_name

    local particleName = "particles/units/heroes/hero_phoenix/phoenix_fire_spirits.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( pfx, 1, Vector( numSpirits, 0, 0 ) )
	for i=1, 4 do
		ParticleManager:SetParticleControl( pfx, 8+i, Vector( 1, 0, 0 ) )
	end

    local sub_ability_name	= keys.sub_ability_name
	local main_ability_name	= ability:GetAbilityName()
	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )


end

function LaunchFire(keys)
    local caster	= keys.caster
	local ability	= keys.ability

    
end

function LevelUpAbility(keys)
    local caster	= keys.caster
	local ability	= keys.ability
end

function initStage(keys)
    local caster	= keys.caster
	local ability	= keys.ability
end