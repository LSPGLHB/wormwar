require('shoot_init')
function createStoneShoot(keys)
		local caster = keys.caster
		local ability = keys.ability
		local speed = ability:GetSpecialValueFor("speed")
		local max_distance = ability:GetSpecialValueFor("max_distance")
		local position = caster:GetAbsOrigin()
		local direction = (ability:GetCursorPosition() - position):Normalized()
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
		creatSkillShootInit(keys,shoot,caster)


		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		moveShoot(keys, shoot, max_distance, direction, speed, particleID, stoneShootBoom, stoneShootBeatbackUnit)
end

function stoneShootBeatbackUnit(keys, shoot, unit)
	local ability = keys.ability
	local beatBackDistance = ability:GetSpecialValueFor("beat_back")
	local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed")
	local canSecHit = 1	  --可以二次撞击
	
	beatBackUnit(keys, shoot, unit, beatBackDistance, beatBackSpeed, canSecHit)
end

function stoneShootBoom(keys,shoot,particleID)
	local ability = keys.ability
	local damage = getApplyDamageValue(keys,shoot)
	for i = 1, #shoot.hitUnit  do
		local unit = shoot.hitUnit[1]
		ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})	
	end
	--[[
	if particleID ~= nil then
		ParticleManager:DestroyParticle(particleID, true)
	end
	shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit,0.7)]]
end