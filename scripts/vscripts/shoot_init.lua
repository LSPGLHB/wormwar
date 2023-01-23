require('skill_operation')
function moveShoot(shoot, max_distance, direction, speed, keys, particleID)
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
			
				if hitType == 3  then --直达不触碰
					if boomType == 1 then --单次伤害
						--onceSkillBoom(keys,shoot)
					end
					if boomType == 2 then --持续性伤害
						--durativeSkillBoom(keys,shoot)
					end
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

function shootHit(shoot, keys)
	local caster = keys.caster
	local ability = keys.ability
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	local hitType = keys.hitType --hitType：1爆炸，2穿透，3直达指定位置，不命中单位
	local beatBackFlag = keys.beatBackFlag -- 0不击退，1未定义，2二级击退
	local boomType = keys.boomType  --boomType:0不是aoe，1普通aoe
	--默认不可穿透
	if hitType == nil then
		hitType = 1
	end
	--默认不击退
	if beatBackFlag == nil then
		beatBackFlag = 0
	end
	--默认不是aoe
	if boomType == nil then
		boomType = 0
	end

	--local PlayerID = caster:GetPlayerID() PlayerResource:GetTeam(PlayerID) print("team========:"..team) print("goodguy2:"..DOTA_TEAM_GOODGUYS) print("badguy3:"..DOTA_TEAM_BADGUYS) print("noteam5:"..DOTA_TEAM_NOTEAM) print("CUSTOM_1=6:"..DOTA_TEAM_CUSTOM_1) print("CUSTOM_2=7:"..DOTA_TEAM_CUSTOM_2)
	--寻找目标
	local searchRadius = 100
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										searchRadius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	local isHitUnit = true   --初始化可击中单位
	for k,unit in pairs(aroundUnits) do
		--local name = unit:GetContext("name")
		local lable =unit:GetUnitLabel()
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.isHealth
		local shootHealth = shoot.isHealth
		if shoot.hitUnit == nil then
			shoot.hitUnit = {}
		end
		--让子弹跟目标只碰撞一次
		--子弹忽略自己，忽略发射者，子弹为穿透弹
		if shoot ~= unit and unit ~= caster and hitType == 2 then
			for i = 0, #shoot.hitUnit  do
				if shoot.hitUnit[i] == unit then
					isHitUnit = false  --如果已经击中过就不再击中
					break
				end
			end
			if isHitUnit then
				table.insert(shoot.hitUnit,unit)
			end
		end
		--遇到敌人实现伤害并返回撞击反馈
		if(casterTeam ~= unitTeam and shootHealth ~= 0 and isHitUnit) then --触碰到的不是自家队伍，且自身法魂不为0，是否实现撞击
			--print("shootHealthEEEE:",shootHealth)
			if(GameRules.skillLabel == lable and unitHealth ~= 0) then --如果碰到的是子弹，且法魂不为0：此处需要比拼法魂大小
				--获取触碰双方的属性--print("shoot-nuit-Type:",shoot.unit_type,unit.unit_type)
				--法魂计算过程
				local tempHealth = shoot:GetHealth() - unit:GetHealth()
				if(tempHealth > 0) then
					shoot:SetHealth(tempHealth)
					unit:SetHealth(0)
					unit.isHealth = 0
				else
					if tempHealth == 0 then
						unit.isHealth = 0
					end
					shoot:SetHealth(0)
					shoot.isHealth = 0
					tempHealth = tempHealth * -1
					unit:SetHealth(tempHealth)	
				end
				return 0
			else --如果碰到的不是子弹
				--返回中弹标记，出发中弹效果
				if hitType == 1 or hitType == 2 then --爆炸弹，--穿透弹,--并实现伤害
					--计算增强或减弱的伤害计算
					local damage = getApplyDamageValue(keys,shoot)
					--撞开击中单位
					if beatBackFlag == 1 then--保留撞击类型
					
					end
					if beatBackFlag == 2 then--会产生二次撞击
						beatBackUnit(keys,shoot,unit,"one")
					end
					ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
					return hitType
				end
				if hitType == 3 then--直达指定位置，中途不命中单位
					return hitType
				end
			end
		else--相同队伍的触碰    	 
			 --不搜索自己，标签为子弹
			if shoot ~= unit and shootLable == lable and isHitUnit then
				--fireStormFlag用于标记该aoe是否已经起作用
				if unit.shootPowerFlag == nil  then
					reinforceEach(unit,shoot,nil) --加强运算
					unit.shootPowerFlag = 1;
				end
			end
		end
	end
	return 0
end


--击退单位
function beatBackUnit(keys,shoot,hitTarget,flag)
	local caster = keys.caster
	local ability = keys.ability
	local powerLv = shoot.power_lv
	hitTarget.power_lv = powerLv
	local beat_back_one = ability:GetSpecialValueFor("beat_back_one")
	local beat_back_speed = ability:GetSpecialValueFor("beat_back_speed")
	local beat_back_two = ability:GetSpecialValueFor("beat_back_two")
	--击退距离受加强削弱影响
	beat_back_one = powerLevelOperation(powerLv, beat_back_one) 
	beat_back_two = powerLevelOperation(powerLv, beat_back_two)
	--print("beat_back_one",beat_back_one)
	local hitTargetDebuff = keys.hitTargetDebuff
	--hitTarget:AddNewModifier(caster, ability, hitTargetDebuff, {Duration = control_time} )--需要调用lua的modefier
	ability:ApplyDataDrivenModifier(caster, hitTarget, hitTargetDebuff, {Duration = -1})

	if flag == "one" then
		shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,shoot.shootHight*-1))--把子弹的高度降到0
	end
	local shootPos = shoot:GetAbsOrigin()
	local targetPos = hitTarget:GetAbsOrigin()
	local beatBackDirection =  (targetPos - shootPos):Normalized() 
	local interval = 0.02
	local speedmod = beat_back_speed * interval
	local bufferTempDis = hitTarget:GetPaddedCollisionRadius()
	local traveled_distance = 0
	--记录击退时间
	local beatTime = GameRules:GetGameTime()
	hitTarget.lastBeatBackTime = beatTime
	local beat_back_distance
	if flag == "one" then
		beat_back_distance = beat_back_one
		--hitTarget.powerLv = powerLv
	end
	if flag == "two" then
		beat_back_distance = beat_back_two
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
	function ()
		if traveled_distance < beat_back_distance and beatTime == hitTarget.lastBeatBackTime then --如果击退时间没被更改继续执行
			local newPosition = hitTarget:GetAbsOrigin() + Vector(beatBackDirection.x, beatBackDirection.y, 0) * speedmod
			local tempLastDis = beat_back_distance - traveled_distance
			--中途可穿模，最后不能穿
			if tempLastDis > bufferTempDis then
				hitTarget:SetAbsOrigin(newPosition)
			else
				FindClearSpaceForUnit( hitTarget, newPosition, false )
			end
			hitTarget:SetOrigin(hitTarget:GetOrigin() + Vector(0,0,0)) --高度问题未解决

			traveled_distance = traveled_distance + speedmod

			if flag == "one" then
				checkSecondHit(keys,hitTarget)
			end
		else
			hitTarget:InterruptMotionControllers( true )
			hitTarget:RemoveModifierByName(hitTargetDebuff)		
			hitTarget.stoneBeatBack = 0
			--EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", caster)
			return nil
		end
		return interval
	end,0)
end

--击退的单位二次击退其他单位
function checkSecondHit(keys,shoot)
	local caster = keys.caster
	--local ability = keys.ability
	local position = shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	local searchRadius = 100
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										searchRadius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)

	for k,unit in pairs(aroundUnits) do
		--local name = unit:GetContext("name")
		local lable =unit:GetUnitLabel()
		local casterTeam = caster:GetTeam()
		local unitTeam = unit:GetTeam()
		if(GameRules.skillLabel ~= lable and shoot ~= unit and casterTeam~=unitTeam and unit.stoneBeatBack ~= 1) then --碰到的不是子弹,不是自己,不是发射技能的队伍,没被该技能碰撞过		
			unit.stoneBeatBack = 1
			beatBackUnit(keys,shoot,unit,"two")
		end
	end
end




--技能爆炸,持续伤害，未完成
function durativeSkillBoom(keys,shoot)
	local ability = keys.ability
	local duration = 4--ability:GetSpecialValueFor("duration")
	local interval = 0.25--ability:GetSpecialValueFor("interval")
	local thinkTime = 0
	local caster = keys.caster
	local particleBoom = staticStromRenderParticles(keys,shoot) --粒子效果生成

	ability:ApplyDataDrivenModifier(caster, shoot, "modifier_boom_storm_datadriven", {})--光环添加

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
		function ()
			--DealDamage(keys,shoot)
			thinkTime = thinkTime + interval
			if thinkTime == duration then
				ParticleManager:DestroyParticle(particleBoom, true)
				return nil
			end
			return interval
		end,0)
	EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)
			
	shoot:ForceKill(true) 
	shoot:AddNoDraw() 
end



