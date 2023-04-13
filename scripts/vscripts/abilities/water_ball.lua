require('shoot_init')
require('skill_operation')
function createWaterBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()  
    local casterPoint = caster:GetAbsOrigin() 
    local max_distance = (skillPoint - casterPoint):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()

	

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
	creatSkillShootInit(keys,shoot,caster)
	--shoot.timer = 0
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)

    moveShoot(keys, shoot, max_distance, direction, particleID, waterBallBoom, nil)


end


--技能爆炸,单次伤害
function waterBallBoom(keys,shoot,particleID)
	--local caster = keys.caster
	local ability = keys.ability
	--local modifierName = keys.modifierName
	--local duration = ability:GetSpecialValueFor("duration") --持续时间
	--local radius = ability:GetSpecialValueFor("radius") --AOE范围
	local delay = 1 --延迟作用时间
	--[[
	if particleID ~= nil then
		ParticleManager:DestroyParticle(particleID, true)
	end
	if delay ~= nil then
		particleID = ParticleManager:CreateParticle(keys.particles_power, PATTACH_ABSORIGIN_FOLLOW , shoot)  --爆炸前悬停特效改变
	end
]]
	if keys.canShotDown == 1 and shoot.isHealth == 0 then
		local particleShotDown = shotDown(keys, shoot)--shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_shotDown,keys.particles_hit_dur)
		shootKill(shoot)--消失
		Timers:CreateTimer(1,function ()
			ParticleManager:DestroyParticle(particleShotDown, true)
			return nil
		end)
	else
		ParticleManager:SetParticleControl(particleID, 13, Vector(0, 1, 0)) --变换粒子效果切换到准备爆炸状态
		Timers:CreateTimer(delay,function ()
			local particleBoom =  waterBallBoomRenderParticles(keys,shoot)-- novaRenderParticles(keys,shoot) --粒子效果生成		
			ParticleManager:DestroyParticle(particleID, true)
			dealSkillBoom(keys,shoot) --实现aoe效果
			shootKill(shoot)--到达尽头消失
			EmitSoundOn("Hero_Gyrocopter.HomingMissile.Destroy", shoot)
			Timers:CreateTimer(2,function ()
				ParticleManager:DestroyParticle(particleBoom, true)
				return nil
			end)
			return nil
		end)
	end
end

function shotDown(keys, shoot)
	local caster = keys.caster
	local ability = keys.ability
	local particleShotDown = ParticleManager:CreateParticle("particles/21huojingling_jiluo.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleShotDown, 3, shoot:GetAbsOrigin())
	return particleShotDown
end

function waterBallBoomRenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local radius = finalValueOperation(ability:GetSpecialValueFor("radius"),shoot.range_bonus,shoot.range_precent_base_bonus,shoot.range_precent_final_bonus)
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleBoom, 3, shoot:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 1, 0))
	return particleBoom
end



function dealSkillBoom(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local hitTargetDebuff = keys.hitTargetDebuff
	local duration = ability:GetSpecialValueFor("duration") --冰冻持续时间
	local radius = finalValueOperation(ability:GetSpecialValueFor("radius"),shoot.range_bonus,shoot.range_precent_base_bonus,shoot.range_precent_final_bonus)--AOE范围
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										radius,
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
			ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = duration})
			local damage = getAbilityShootDamageValue(shoot)
			ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
		end
		--如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
		if lable == GameRules.skillLabel and unitHealth ~= 0 then
			reinforceEach(unit,shoot,nil)
		end
	end
end
