require('skill_operation')
function moveShoot(keys, shoot, max_distance, direction, speed, particleID, boomCallback, beatBackUnitCallBack)
	local traveled_distance = 0 --初始化已经飞行的距离
	moveShootInit(keys,shoot,direction)
	--影响弹道的buff--测试速度调整
	speed = skillSpeedOperation(keys,speed)

	shoot.isBreak = 0 --初始化不跳出
	
	local shootHealthMax = shoot:GetHealth()
	local shootHealthSend = shootHealthMax * 0.5
	local shootHealthStep = shootHealthMax * 0.5 * speed / 10
	shoot:SetHealth(shootHealthSend)
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		if traveled_distance < max_distance then
			if shoot.isBreak == 1 then
				return nil
			end
			moveShootTimerInit(keys,shoot,direction,speed)
			if shootHealthSend < shootHealthMax then
				shootHealthSend = shootHealthSend + shootHealthStep
				shoot:SetHealth(shootHealthSend)
			end
			--技能加强或减弱粒子效果实现
			powerShootParticleOperation(keys,shoot,particleID)
			traveled_distance = traveled_distance + speed
			--子弹命中目标
			local isHitType = shootHit(keys, shoot, beatBackUnitCallBack)
			--击中目标，行程结束
			if isHitType == 1 then
				shootPenetrateParticleOperation(keys,shoot)--中弹效果
				if boomCallback ~= nil then
					boomCallback(keys,shoot,particleID) --到达尽头启动AOE
				end
				return nil
			end
			--击中目标，行程继续
			if isHitType == 2 then
				shootPenetrateParticleOperation(keys,shoot)--中弹效果
				if boomCallback ~= nil then
					boomCallback(keys,shoot,particleID) --到达尽头启动AOE
				end
				return 0.02
			end
			--到达指定位置，不命中目标
			if isHitType == 3 then
				return 0.02
			end
			--法魂被击破，行程结束
			--获得子弹法魂是否为0
			if shoot.isHealth == 0  then
				if shoot then
					boomCallback(keys,shoot,particleID) 
					--shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_shotDown,keys.particles_hit_dur)
					return nil
				end
			end
		else
			--超出射程没有命中
			if shoot then		
				if keys.isAOE == 1 and boomCallback ~= nil then --直达尽头发动AOE	
					boomCallback(keys,shoot,particleID) --启动AOE
				else
					if particleID then
						ParticleManager:DestroyParticle(particleID, true)
					end
					shootKill(shoot)--到达尽头消失
				end
				return nil
			end
		end
      return 0.02
     end,0)
end

function moveShootInit(keys,shoot,direction)
	shoot.shootHight = 100 --子弹高度
	--shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射初始方向
	--shoot:SetAbsOrigin(shoot:GetAbsOrigin() + direction * 50 + Vector(0,0,shoot.shootHight)) --发射高度
	if keys.hitType == nil then--hitType：1爆炸，2穿透，3直达指定位置，不命中单位
		keys.hitType = 1
	end
	if keys.isTrack == nil then
		keys.isTrack = 0
	end
	if keys.isAOE == nil then
		keys.isAOE = 0
	end
	if keys.canShotDown == nil then
		keys.canShotDown = 0
	end
end

function moveShootTimerInit(keys,shoot,direction,speed)
	local shootTempPos = shoot:GetAbsOrigin()
	if keys.isTrack == 1 then
		direction = (keys.trackUnit:GetAbsOrigin() - Vector(shootTempPos.x, shootTempPos.y, 0)):Normalized()
	end
	--shootTempPos = shootTempPos + Vector(0 ,0 ,shoot.shootHight)
	local newPos = shootTempPos + direction * speed
	local groundPos = GetGroundPosition(newPos, shoot)
	shoot:SetAbsOrigin(Vector(groundPos.x, groundPos.y, groundPos.z + shoot.shootHight))
	--FindClearSpaceForUnit( shoot, groundPos, false )
	--shoot:SetAbsOrigin(shoot:GetAbsOrigin() + Vector(0,0,shoot.shootHight))--把子弹控制在离地面一定高度shoot:SetAbsOrigin(shoot:GetAbsOrigin()+ Vector(0,0,shoot.shootHight))
end


function shootHit(keys, shoot, beatBackUnitCallBack)
	local caster = keys.caster
	local ability = keys.ability
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	local hitType = keys.hitType --hitType：1碰撞伤害，2穿透伤害，3直达指定位置，不命中单位
	local hitRange = ability:GetLevelSpecialValueFor("hit_range", ability:GetLevel() - 1)
	--默认不可穿透
	if hitType == nil then
		hitType = 1
	end
	--默认不击退
	if keys.isBeatBack == nil then
		keys.isBeatBack = 0
	end
	--local PlayerID = caster:GetPlayerID() PlayerResource:GetTeam(PlayerID) print("team========:"..team) print("goodguy2:"..DOTA_TEAM_GOODGUYS) print("badguy3:"..DOTA_TEAM_BADGUYS) print("noteam5:"..DOTA_TEAM_NOTEAM) print("CUSTOM_1=6:"..DOTA_TEAM_CUSTOM_1) print("CUSTOM_2=7:"..DOTA_TEAM_CUSTOM_2)
	--寻找目标
	local searchRadius = hitRange
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										searchRadius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	local isHitUnit = true   --初始化设单位为可击中状态
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
		--子弹忽略自己，忽略发射者，忽略友军，忽略子弹，标签不是技能子弹--子弹为穿透弹
		if shoot ~= unit and unit ~= caster and unitTeam ~= casterTeam and GameRules.skillLabel ~= lable then --and hitType == 2 then
			for i = 1, #shoot.hitUnit  do
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
			if(GameRules.skillLabel == lable and unitHealth ~= 0) then --如果碰到的是子弹，且法魂不为0：此处需要比拼法魂大小
				--获取触碰双方的属性--print("shoot-nuit-Type:",shoot.unit_type,unit.unit_type)
				--法魂计算过程
				local tempHealth = shoot:GetHealth() - unit:GetHealth()
				if(tempHealth > 0) then
					shoot:SetHealth(tempHealth)
					--unit:SetHealth(0) --不能设为0，否则不能kill掉进程
					unit.isHealth = 0
					shootKill(unit)--直接kill掉进程
				else
					if tempHealth == 0 then
						unit.isHealth = 0
					end
					--shoot:SetHealth(0.1)
					shoot.isHealth = 0
					shootKill(shoot)
					tempHealth = tempHealth * -1
					unit:SetHealth(tempHealth)
				end
				return 0
			else --如果碰到的不是子弹
				--返回中弹标记，出发中弹效果
				if hitType == 1 or hitType == 2 then --爆炸弹，--穿透弹,--并实现伤害
					--撞开击中单位
					if keys.isBeatBack == 1 then--会产生撞击
						beatBackUnitCallBack(keys, shoot, unit)
					end
					return hitType
				end
				if hitType == 3 then--直达指定位置，中途不命中单位
					return hitType
				end
			end
		else--相同队伍的触碰    	 
			 --不搜索自己，标签为子弹
			if shoot ~= unit and GameRules.skillLabel == lable and isHitUnit then
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

function creatSkillShootInit(keys,shoot,owner)
	shoot:SetOwner(owner)
	shoot.unit_type = keys.unitType --用于计算克制和加强
	shoot.power_lv = 0 --用于实现克制和加强
	shoot.power_flag = 0 --用于实现克制和加强
	shoot.hitUnit = {}--用于记录命中的目标
end

function shootKill(shoot)
	shoot:ForceKill(true)
	shoot:AddNoDraw()
end


--击退单位
function beatBackUnit(keys,shoot,hitTarget,beatBackDistance,beatBackSpeed,isSkillHit,canSecHit)--isSkillHit:是否技能击中 ,canSecHit:是否能二次撞击1为能
	local caster = keys.caster
	local ability = keys.ability
	local powerLv = shoot.power_lv
	hitTarget.power_lv = powerLv
	--击退距离受加强削弱影响
	beatBackDistance = powerLevelOperation(powerLv, beatBackDistance) 
	local hitTargetDebuff = keys.hitTargetDebuff
	--hitTarget:AddNewModifier(caster, ability, hitTargetDebuff, {Duration = control_time} )--需要调用lua的modefier
	ability:ApplyDataDrivenModifier(caster, hitTarget, hitTargetDebuff, {Duration = -1})
	local shootPos = shoot:GetAbsOrigin()
	local tempShootPos = shootPos
	if isSkillHit == 1 then
		tempShootPos = Vector(shootPos.x,shootPos.y,0)--(shoot:GetAbsOrigin() + Vector(0,0,shoot.shootHight*-1))--把子弹的高度降到0
	end
	--local shootPos = shoot:GetAbsOrigin()
	local tempTargetPos = hitTarget:GetAbsOrigin()
	local targetPos = Vector(tempTargetPos.x ,tempTargetPos.y ,0)
	local beatBackDirection =  (targetPos - tempShootPos):Normalized()
	local interval = 0.02
	local speedmod = beatBackSpeed * interval
	local bufferTempDis = hitTarget:GetPaddedCollisionRadius()
	local traveled_distance = 0
	--记录击退时间
	local beatTime = GameRules:GetGameTime()
	hitTarget.lastBeatBackTime = beatTime
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
	function ()
		if traveled_distance < beatBackDistance and beatTime == hitTarget.lastBeatBackTime then --如果击退时间没被更改继续执行
			local newPosition = hitTarget:GetAbsOrigin() +  beatBackDirection * speedmod -- Vector(beatBackDirection.x, beatBackDirection.y, 0) * speedmod
			local groundPos = GetGroundPosition(newPosition, hitTarget)
			--中途可穿模，最后不能穿
			local tempLastDis = beatBackDistance - traveled_distance
			if tempLastDis > bufferTempDis then
				hitTarget:SetAbsOrigin(groundPos)
			else
				FindClearSpaceForUnit( hitTarget, groundPos, false )
			end
			traveled_distance = traveled_distance + speedmod
			if canSecHit == 1 then --进入第二次撞击
				checkSecondHit(keys,hitTarget)
			end
		else
			hitTarget:InterruptMotionControllers( true )
			hitTarget:RemoveModifierByName(hitTargetDebuff)		
			hitTarget.beatBackFlag = 0  --变回可碰撞状态
			--EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", caster)
			return nil
		end
		return interval
	end,0)
end

--击退的单位二次击退其他单位
function checkSecondHit(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
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
		if(GameRules.skillLabel ~= lable and shoot ~= unit and casterTeam~=unitTeam and unit.beatBackFlag ~= 1) then --碰到的不是子弹,不是自己,不是发射技能的队伍,没被该技能碰撞过		
			unit.beatBackFlag = 1 --碰撞中，变成不可再碰撞状态
			local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed")
			local beatBackDistance = ability:GetSpecialValueFor("beat_back_two")
			beatBackUnit(keys,shoot,unit,beatBackDistance,beatBackSpeed,0,0)
		end
	end
end



