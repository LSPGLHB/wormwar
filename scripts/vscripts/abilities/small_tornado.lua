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
		moveShoot(keys, shoot, max_distance, direction, speed, particleID, smallTornadoBoom, smallTornadoBeatBack)
end

function smallTornadoBoom(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失
    smallTornadoDuration(keys,shoot) --实现持续光环效果以及粒子效果
end

function smallTornadoDuration(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
    local aoeDebuff = keys.hitTargetDebuff
    local aoe_duration_radius = ability:GetSpecialValueFor("aoe_duration_radius") --AOE持续作用范围
    local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
    local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
    local tempTimer = 0
	local interval = 0.02
    local particleBoom = smallTornadoRenderParticles(keys,shoot)
    Timers:CreateTimer(0,function ()
		local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										aoe_duration_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
        for k,unit in pairs(aroundUnits) do
            local unitTeam = unit:GetTeam()
            local unitHealth = unit.isHealth
            local lable = unit:GetUnitLabel()
            --只作用于敌方,非技能单位
            if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
				local damage = getApplyDamageValue(keys,shoot)
				damage = damage * interval
				ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

                ability:ApplyDataDrivenModifier(caster, unit, aoeDebuff, {Duration = aoe_duration})
				
				local beatBackSpeed = ability:GetSpecialValueFor("G_speed")
				local beatBackDistance = beatBackSpeed * interval--ability:GetSpecialValueFor("max_distance")
				local isSkillHit = 1  --是技能撞击
				local canSecHit = 0	  --可以二次撞击
				
				--beatBackUnit(keys, shoot, unit, beatBackDistance, beatBackSpeed, isSkillHit, canSecHit)
            end
            --如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
            if lable == GameRules.skillLabel and unitHealth ~= 0 then
                reinforceEach(unit,shoot,nil)
            end
        end
        if tempTimer < aoe_duration then
            tempTimer = tempTimer + interval
            return interval
        else 
            ParticleManager:DestroyParticle(particleBoom, true)
            EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)	
            shoot:ForceKill(true)
            shoot:AddNoDraw()
            return nil
        end
	end)
end

function smallTornadoRenderParticles(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("aoe_duration") --持续时间
	local radius = ability:GetSpecialValueFor("aoe_duration_radius")
	local particleBoom = ParticleManager:CreateParticle(keys.durationParticlesBoom, PATTACH_WORLDORIGIN, caster)
    local shootPos = shoot:GetAbsOrigin()
	ParticleManager:SetParticleControl(particleBoom, 0, Vector(shootPos.x, shootPos.y, shootPos.z + shoot.shootHight))
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 2, Vector(duration, 0, 0))
	return particleBoom
end


function smallTornadoBeatBack(keys, shoot, unit)
	local ability = keys.ability
	local beatBackSpeed = ability:GetSpecialValueFor("speed")
	local beatBackDistance = beatBackSpeed * 0.02--ability:GetSpecialValueFor("max_distance")
	local isSkillHit = 1  --是技能撞击
	local canSecHit = 0	  --可以二次撞击
	
	takeAwayUnit(keys, shoot, unit)
end

--带走被撞击单位
function takeAwayUnit(keys,shoot,hitTarget)
	local caster = keys.caster
	local ability = keys.ability
	local speed = shoot.speed
	local direction = shoot.direction
	local hitTargetDebuff = keys.hitTargetDebuff
	local interval = 0.02
	ability:ApplyDataDrivenModifier(caster, hitTarget, hitTargetDebuff, {Duration = interval})
	local newPosition = hitTarget:GetAbsOrigin() +  direction * speed 
	local groundPos = GetGroundPosition(newPosition, hitTarget)
	hitTarget:SetAbsOrigin(groundPos)
	--FindClearSpaceForUnit( hitTarget, groundPos, false )
end