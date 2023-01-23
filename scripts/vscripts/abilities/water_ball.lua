require('shoot_init')
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
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
    ParticleManager:SetParticleControlEnt(particleID, cp , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)
    
    moveShootByAoe(shoot, max_distance, direction, speed, keys, particleID)


end

function moveShootByAoe(shoot, max_distance, direction, speed, keys, particleID)
	local traveled_distance = 0
	shoot.shootHight = 100 --子弹高度
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + direction * 50 + Vector(0,0,shoot.shootHight)) --发射高度
	local hitType = keys.hitType --hitType：1爆炸，2穿透，3直达指定位置，不命中单位
	--默认爆炸弹
	if hitType == nil then
		hitType = 1
	end
	local boomType = keys.boomType  --boomType:0不是aoe，1普通aoe
	--默认不是aoe
	if boomType == nil then
		boomType = 0
	end
	--影响弹道的buff--测试速度调整
	speed = skillSpeedOperation(keys,speed)

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		if traveled_distance < max_distance then
			local newPos = shoot:GetOrigin() + direction * speed
			FindClearSpaceForUnit( shoot, newPos, false )
			shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,shoot.shootHight))--shoot:SetAbsOrigin(shoot:GetOrigin()+ Vector(0,0,shoot.shootHight))

			--技能加强或减弱粒子效果实现
			powerShootParticleOperation(keys,shoot,particleID)
			
			traveled_distance = traveled_distance + speed
			--子弹命中目标
			local isHitType = shootHit(shoot, keys)
			--获得子弹法魂是否为0
			local isHealth = shoot.isHealth
			--击中目标，行程结束
			if isHitType == 1 then
				particleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit,0.7)
				return nil
			end
			--击中目标，行程继续
			if isHitType == 2 then
				--中弹粒子效果
				ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
				--中弹声音
				EmitSoundOn(keys.sound_hit, shoot)
				return 0.02
			end
			--到达指定位置，不命中目标
			if isHitType == 3 then
				return 0.02
			end
			--法魂被击破，行程结束
			if isHealth == 0 then
				if shoot then
					particleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit)
					return nil
				end
			end
		else
			--超出射程没有命中
			if shoot then
				if particleID then
					ParticleManager:DestroyParticle(particleID, true)
				end	
				if hitType == 3  then
		
					waterBallBoom(keys,shoot)

				else
					shoot:ForceKill(true)
					shoot:AddNoDraw()
				end
				return nil
			end
		end
      return 0.02
     end,0)
end



--技能爆炸,单次伤害
function waterBallBoom(keys,shoot)
	--local caster = keys.caster
	local ability = keys.ability
	--local modifierName = keys.modifierName
	local duration = ability:GetSpecialValueFor("duration") --持续时间
	--local radius = ability:GetSpecialValueFor("radius") --AOE范围
	local delay = 1 --延迟作用时间
	local particleID
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