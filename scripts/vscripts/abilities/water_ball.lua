require('shoot_init')
require('skill_operation')
function createWaterBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local casterPoint = caster:GetAbsOrigin() 
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = caster:GetForwardVector()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    shoot:SetOwner(caster)
    shoot.unit_type = keys.unitType
    shoot.power_lv = 0
    shoot.power_flag = 0
    local cp = keys.cp
    if cp == nil then
        cp = 0
    end
	shoot.timer = 0
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, cp , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)

    moveShoot(shoot, max_distance, direction, speed, nil, keys, particleID, waterBallBoom)


end


--技能爆炸,单次伤害
function waterBallBoom(keys,shoot,particleID)
	--local caster = keys.caster
	local ability = keys.ability
	--local modifierName = keys.modifierName
	local duration = ability:GetSpecialValueFor("duration") --持续时间
	--local radius = ability:GetSpecialValueFor("radius") --AOE范围
	local delay = 1 --延迟作用时间
	if particleID ~= nil then
		ParticleManager:DestroyParticle(particleID, true)
	end
	
	if delay ~= nil then
		particleID = ParticleManager:CreateParticle(keys.particles_power, PATTACH_ABSORIGIN_FOLLOW , shoot)  --爆炸前悬停特效改变
	end

	Timers:CreateTimer(delay,function ()
		local particleBoom = novaRenderParticles(keys,shoot) --粒子效果生成		
		ParticleManager:DestroyParticle(particleID, true)
		dealSkillBoom(keys,shoot) --实现aoe效果
		Timers:CreateTimer(1,function ()
			ParticleManager:DestroyParticle(particleBoom, true)
			EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)		
			return nil
		end)
		shoot:ForceKill(true)
		shoot:AddNoDraw()
		return nil
	end)
end

function novaRenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleBoom, 0, shoot:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 1, radius*2))
end



function dealSkillBoom(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local hitTargetDebuff = keys.hitTargetDebuff
	local duration = ability:GetSpecialValueFor("duration") --冰冻持续时间
	local radius = ability:GetSpecialValueFor("radius") --AOE范围
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
			local damage = getApplyDamageValue(keys,shoot)
			ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
		end
		--如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
		if lable == GameRules.skillLabel then
			reinforceEach(unit,shoot,nil)
		end
	end
end

--[[
function moveShootByTest(shoot, max_distance, direction, minSpeed, maxSpeed, keys, particleID, callback)
	local traveled_distance = 0

	--local speed = minSpeed
	moveShootInit(keys,shoot,direction)
	--影响弹道的buff--测试速度调整
	minSpeed = skillSpeedOperation(keys,minSpeed)
	if maxSpeed ~= nil then
		maxSpeed = skillSpeedOperation(keys,maxSpeed)
	end
	Timers:CreateTimer(0,function ()
		if traveled_distance < max_distance then
			moveShootTimerInit(keys,shoot,direction,minSpeed)
			if maxSpeed ~= nil and minSpeed < maxSpeed then
				minSpeed = minSpeed + 20
			end
			--技能加强或减弱粒子效果实现
			powerShootParticleOperation(keys,shoot,particleID)
			traveled_distance = traveled_distance + minSpeed
			--子弹命中目标
			local isHitType = shootHit(shoot, keys)
			--击中目标，行程结束
			if isHitType == 1 then
				shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit,0.7)
				shoot.timer = 1
				return nil
			end
			--击中目标，行程继续
			if isHitType == 2 then
				shootPenetrateParticleOperation(keys,shoot)
				return 0.02
			end
			--到达指定位置，不命中目标
			if isHitType == 3 then
				return 0.02
			end
			--法魂被击破，行程结束
			--获得子弹法魂是否为0
			if shoot.isHealth == 0 then
				if shoot then
					shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit)
					return nil
				end
			end
		else
			--超出射程没有命中
			if shoot then
				if particleID then
					ParticleManager:DestroyParticle(particleID, true)
				end	
			
				if keys.hitType == 3  then --直达不触碰
					if keys.isAOE == 1 then --单次伤害
						--onceSkillBoom(keys,shoot)
						callback(keys,shoot)
					end
					if keys.isAOE == 2 then --持续性伤害
						--durativeSkillBoom(keys,shoot)
					end
				else
					shootKill(shoot)
				end
				shoot.timer = 1
				return nil
			end
		end
      return 0.02
     end)
end

function dealSkillBoom(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local hitTargetDebuff = keys.hitTargetDebuff
	local duration = ability:GetSpecialValueFor("duration") --冰冻持续时间
	local radius = ability:GetSpecialValueFor("radius") --AOE范围
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

		end
		--如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
		if lable == GameRules.skillLabel then
			reinforceEach(unit,shoot,nil)
		end
	end
end



--静电风暴方案，未用
function staticStromRenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration") --持续时间
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleBoom, 0, shoot:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 2, Vector(duration, 0, 0))
	return particleBoom
end

]]