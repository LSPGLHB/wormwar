require('shoot_init')
require('skill_operation')
function createSmallTornado(keys)
		local caster = keys.caster
		local ability = keys.ability
		local speed = ability:GetSpecialValueFor("speed")
		local max_distance = ability:GetSpecialValueFor("max_distance")
		local position = caster:GetAbsOrigin()
		local direction = (ability:GetCursorPosition() - position):Normalized()
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster)

		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)
		moveShoot(keys, shoot, max_distance, direction, speed, particleID,smallTornadoBoom)
end

function smallTornadoBoom(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失
    
    smallTornadoDuration(keys,shoot) --实现持续光环效果以及粒子效果


end

function smallTornadoDuration(keys,shoot)
    
end

function smallTornadoRenderParticles(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("G_duration") --持续时间
	local radius = ability:GetSpecialValueFor("aoe_radius")
	local particleBoom = ParticleManager:CreateParticle(keys.durationParticlesBoom, PATTACH_WORLDORIGIN, caster)
    local shootPos = shoot:GetAbsOrigin()
	ParticleManager:SetParticleControl(particleBoom, 0, Vector(shootPos.x, shootPos.y, shootPos.z + shoot.shootHight))
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 2, Vector(duration, 0, 0))
	return particleBoom
end
