require('shoot_init')
require('skill_operation')
function getReadyForIceArrow(keys)
    local caster	= keys.caster
	local ability	= keys.ability
    local modifierStageName	= keys.modifier_caster_buff_name
	local numSpirits	= ability:GetSpecialValueFor("spirit_count")
    local particleName = keys.particles_nm
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( pfx, 1, Vector( numSpirits, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 6, Vector( numSpirits, 0, 0 ) )
	for i=1, numSpirits do
		ParticleManager:SetParticleControl( pfx, 8+i, Vector( 1, 0, 0 ) )
	end
	caster.ice_arrow_numSpirits	= numSpirits
	caster.ice_arrow_pfx = pfx
	caster:SetModifierStackCount( modifierStageName, caster, numSpirits )

    local ability_a_name = keys.ability_a_name
    local ability_b_name = keys.ability_b_name
	caster:SwapAbilities( ability_a_name, ability_b_name, false, true )
	initDurationBuff(keys)
end

function launchIceArrow(keys)
    local caster	= keys.caster
	local ability	= keys.ability
	local modifierStageName	= keys.modifier_caster_buff_name
	local skillPoint = ability:GetCursorPosition()
	local casterPoint = caster:GetAbsOrigin()
	local speed = ability:GetSpecialValueFor("speed")
	local max_distance = ability:GetSpecialValueFor("max_distance")
	local direction = (skillPoint - casterPoint ):Normalized() 
	local ability_a_name = caster:FindAbilityByName( keys.ability_a_name )	
	local currentStack	= caster:GetModifierStackCount( modifierStageName, ability_a_name )
	currentStack = currentStack - 1
	caster:SetModifierStackCount( modifierStageName, caster, currentStack )
	local position = caster:GetAbsOrigin()
	local shootCount = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function ()
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
		creatSkillShootInit(keys,shoot,caster)
		print("shoot",shoot.power_lv,shoot.damage) --此处显示正常
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)--"attach_hitloc"
		moveShoot(keys, shoot, max_distance, direction, particleID, iceArrowHitCallBack, nil)
		shootCount = shootCount + 1
		if shootCount < 2 then
			return 0.5
		else
			return nil
		end
	end,0)

	-- Update the particle FX
	local pfx = caster.ice_arrow_pfx
	ParticleManager:SetParticleControl( pfx, 1, Vector( currentStack, 0, 0 ) )
	for i=1, caster.ice_arrow_numSpirits do
		local radius = 0
		if i <= currentStack then
			radius = 1
		end
		ParticleManager:SetParticleControl( pfx, 8+i, Vector( radius, 0, 0 ) )
	end
	-- Remove the stack modifier if all the spirits has been launched.
	if currentStack == 0 then
		caster:RemoveModifierByName( modifierStageName )
	end
end

function iceArrowHitCallBack(keys,shoot,particleID)
	local caster = keys.caster
	local ability = keys.ability
	local hitTargetDebuff = keys.modifier_ice_arrow_debuff_name
	local duration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间

	local stackCount = 0 --caster:GetModifierStackCount( modifierStageName, ability_a_name )
	print("shoot4",shoot.power_lv,shoot.damage)
	for i = 1, #shoot.hitUnits  do
		local unit = shoot.hitUnits[i]
		local damage = getApplyDamageValue(shoot)
		ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})	
		local tempModifier = unit:FindModifierByName(hitTargetDebuff)
        if tempModifier == nil then
            stackCount = 1
		else
			stackCount = unit:GetModifierStackCount( hitTargetDebuff, ability_b_name )
			stackCount = stackCount + 1
        end
		duration = duration * stackCount
		ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = duration})
		unit:SetModifierStackCount( hitTargetDebuff, caster, stackCount )
	end
	if particleID ~= nil then
		ParticleManager:DestroyParticle(particleID, true)
	end
	shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit,keys.particles_hit_dur)
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


function endSkill(keys)
    local caster	= keys.caster
	local ability	= keys.ability

	local pfx = caster.ice_arrow_pfx
	ParticleManager:DestroyParticle( pfx, false )

	-- Swap main ability
	local ability_a_name	= keys.ability_a_name
	local ability_b_name	= keys.ability_b_name
	caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
end