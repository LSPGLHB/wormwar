require('shoot_init')
require('skill_operation')
function createThunderBall(keys)
		local caster = keys.caster
		local ability = keys.ability
		local speed = ability:GetSpecialValueFor("speed")
		local max_distance = ability:GetSpecialValueFor("max_distance")
		local position = caster:GetAbsOrigin()
		local direction = (ability:GetCursorPosition() - position):Normalized()
		local directionTable ={}
		table.insert(directionTable,direction)
		--local tempPos = position + direction * 1000
		--local r = 1--direction.y / math.sin(math.atan2(direction.x, direction.y))
		local angle23 = 0.1 * math.pi
		local newX2 = math.cos(math.atan2(direction.y, direction.x) - angle23)
		local newY2 = math.sin(math.atan2(direction.y, direction.x) - angle23)
		local newX3 = math.cos(math.atan2(direction.y, direction.x) + angle23)
		local newY3 = math.sin(math.atan2(direction.y, direction.x) + angle23)
		local direction2 = Vector(newX2, newY2, direction.z)
		table.insert(directionTable,direction2)
		local direction3 = Vector(newX3, newY3, direction.z)
		table.insert(directionTable,direction3)
		for i = 1, 3, 1 do
			--print("direction:",directionTable[i])
			local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
			creatSkillShootInit(keys,shoot,caster)

			local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
			ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)
			moveShoot(keys, shoot, max_distance, directionTable[i], speed, particleID, thunderBallBoom, nil)
		end
		
end

function thunderBallBoom(keys,shoot,particleID)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration") --debuff持续时间
	local damage = getApplyDamageValue(keys,shoot)
	for i = 1, #shoot.hitUnit  do
		local unit = shoot.hitUnit[i]
		ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
		ability:ApplyDataDrivenModifier(caster, unit, keys.modifierDebuffName, {Duration = duration})
	end

	if particleID ~= nil then
		ParticleManager:DestroyParticle(particleID, true)
	end
	shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit,keys.particles_hit_dur)
end