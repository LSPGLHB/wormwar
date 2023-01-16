require('damage_operation')

function shootHit(shoot, keys, hitOver)
	local caster = keys.caster
	local ability = keys.ability
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	--[[local PlayerID = caster:GetPlayerID() PlayerResource:GetTeam(PlayerID) print("team========:"..team) print("goodguy2:"..DOTA_TEAM_GOODGUYS) print("badguy3:"..DOTA_TEAM_BADGUYS) print("noteam5:"..DOTA_TEAM_NOTEAM) print("CUSTOM_1=6:"..DOTA_TEAM_CUSTOM_1) print("CUSTOM_2=7:"..DOTA_TEAM_CUSTOM_2)]]
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
	local isHitUnit = true
	for k,unit in pairs(aroundUnits) do
		--local name = unit:GetContext("name")
		local lable =unit:GetUnitLabel()
		local shootLable = "shootLabel"
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.isHealth--:GetContext("isHealth")
		local shootHealth = shoot.isHealth--:GetContext("isHealth")
		
		if shoot.hitUnit == nil then
			shoot.hitUnit = {}
		end
		--让子弹跟目标只碰撞一次
		--子弹忽略自己，忽略发射者，子弹为穿透弹
		if shoot ~= unit and unit ~= caster and hitOver == 2 then
			for i = 0, #shoot.hitUnit  do
				if shoot.hitUnit [i] == unit then
					isHitUnit = false
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
			if(shootLable == lable and unitHealth ~= 0) then --碰到的是子弹，且法魂不为0
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
			else --碰到的不是子弹
				--撞开击中单位
				beatBackUnit(keys,shoot,unit,"one")
				local damage = getApplyDamageValue(keys,shoot)
				--实现伤害
				ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

				--返回中弹标记，出发中弹效果
				if hitOver == 1 then --爆炸弹
					return 1
				end
				if hitOver == 2 then --穿透弹
					return 2
				end
			end
		else--相同队伍的触碰    	 
			 --不搜索自己，标签为子弹
			if shoot ~= unit and shootLable == lable and isHitUnit then			
				--fireStormFlag:标记该aoe是否已经起作用
				if unit.shootPowerFlag == nil  then
					reinforceEach(unit,shoot,nil) --加强或削弱运算
					unit.shootPowerFlag = 1;
				end
			end
		end
	end
	return 0
end


function moveShootByBuff(shoot, max_distance, direction, speed, ability, keys, particleID)
	local traveled_distance = 0
	shoot.shootHight = 100
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + direction * 50 + Vector(0,0,shoot.shootHight)) --发射高度
	--影响弹道的buff
	local caster = keys.caster
	--local unit = keys.unit
	local hitOver = keys.hitOver --子弹类型，1：爆炸弹，2：穿透弹
	--默认不可穿透
	if hitOver == nil then
		hitOver = 1
	end
	local speed_up_per_stack = caster.speed_up_per_stack
	local item_bonus_shoot_speed = getShootPower(caster, "item_shoot_speed")--caster.item_bonus_shoot_speed
	if speed_up_per_stack == nil then
		speed_up_per_stack = 0
	end
	if item_bonus_shoot_speed == nil then
		item_bonus_shoot_speed = 0
	end
	local buff_modifier = "modifier_shoot_speed_up_buff"
	local speed_up_stacks = 0
	if caster:HasModifier(buff_modifier) then
		speed_up_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	end
	local buff_speed_up = speed_up_stacks * speed_up_per_stack
	speed = (speed  + buff_speed_up  + item_bonus_shoot_speed) * 0.02
	
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		if traveled_distance < max_distance then
			local newPos = shoot:GetOrigin() + direction * speed
			FindClearSpaceForUnit( shoot, newPos, false )
			shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,shoot.shootHight))
			--shoot:SetAbsOrigin(shoot:GetOrigin()+ Vector(0,0,shoot.shootHight))
			--判断是否有加强
			if shoot.power_lv > 0 and shoot.power_flag == 1 then
				ParticleManager:DestroyParticle(particleID, true)
				particleID = ParticleManager:CreateParticle(keys.particles_power, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end
			if shoot.power_lv < 0 and shoot.power_flag == 1  then
				ParticleManager:DestroyParticle(particleID, true)
				particleID = ParticleManager:CreateParticle(keys.particles_weak, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end
			traveled_distance = traveled_distance + speed
			--子弹命中目标
			local isHit = shootHit(shoot, keys, hitOver)
			--获得子弹法魂是否为0
			local isHealth = shoot.isHealth--:GetContext("isHealth")

			--击中目标，行程结束
			if isHit == 1 then
				local destroyParticleID = particleID
				local showParticlesName = keys.particles_hit
				local soundName = keys.sound_hit
				particleOperation(shoot,destroyParticleID,showParticlesName,soundName,0.7)
				return nil
			end
			--击中目标，行程继续
			if isHit == 2 then
				--中弹粒子效果
				ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
				--中弹声音
				EmitSoundOn(keys.sound_hit, shoot)

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
				shoot:ForceKill(true)
				shoot:AddNoDraw()
				return nil
			end
		end
      return 0.02
     end,0)
end


function beatBackUnit(keys,shoot,hitTarget,flag)
	local caster = keys.caster
	local ability = keys.ability
	local beat_back_one = ability:GetSpecialValueFor("beat_back_one")
	local beat_back_speed = ability:GetSpecialValueFor("beat_back_speed")
	local beat_back_two = ability:GetSpecialValueFor("beat_back_two")
	
	--local control_time = beat_back_aoe / beat_back_speed * 1.5
	local hitTargetDebuff = keys.hitTargetDebuff
	--print("hitTargetDebuff:",hitTargetDebuff)
	--hitTarget:AddNewModifier(caster, ability, hitTargetDebuff, {Duration = control_time} )--需要调用lua的modefier
	ability:ApplyDataDrivenModifier(caster, hitTarget, hitTargetDebuff, {Duration = -1})

	
	if flag == "one" then
		shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,shoot.shootHight*-1))--把子弹的高度降到0
	end
	local shootPos = shoot:GetAbsOrigin()
	local targetPos = hitTarget:GetAbsOrigin()
	
	local beatBackDirection =  (targetPos - shootPos):Normalized() --这里不同单位碰撞的结果不一样
	--print("beatBackDirection:===",beatBackDirection)
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
			traveled_distance = traveled_distance + speedmod

			--print("ininin=====",flag,"==",newPosition,"====",GameRules:GetGameTime())

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
		local shootLable = "shootLabel"
		--local unitTeam = unit:GetTeam()
		if(shootLable ~= lable and shoot ~= unit and unit.stoneBeatBack ~= 1) then --碰到的不是子弹,不是自己,没被该技能碰撞过		
			print("hithithit")
			unit.stoneBeatBack = 1
			beatBackUnit(keys,shoot,unit,"two")
		end

	end

end


--充能用的冷却
function shoot_start_cooldown( caster, charge_replenish_time )
	caster.shoot_pro_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.shoot_pro_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.shoot_pro_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end

--[[
	function shootHit(shoot, keys)
	local caster = keys.caster
	local ability = keys.ability
	local position=shoot:GetAbsOrigin()
	
	local casterTeam = caster:GetTeam()
	
	
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


	for k,unit in pairs(aroundUnits) do
		--local name = unit:GetContext("name")
		local lable =unit:GetUnitLabel()
		local shootLable = "shootLabel"
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.isHealth--:GetContext("isHealth")
		local shootHealth = shoot.isHealth--:GetContext("isHealth")

		--遇到敌人实现伤害并返回撞击反馈
		if(casterTeam ~= unitTeam and shootHealth ~= 0) then --触碰到的不是自家队伍，且自身法魂不为0
			--print("shootHealthEEEE:",shootHealth)
			if(shootLable == lable and unitHealth ~= 0) then --碰到的是子弹，且法魂不为0
				--获取触碰双方的属性
				--local unitType = unit.unit_type
				--local shootType = shoot.unit_type
				--print("shoot-nuit-Type:",shootType,unitType)
				
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
			else --碰到的不是子弹
				
				--setModifiers(keys,unit)
				
				local damage = getApplyDamageValue(keys,shoot)
				--实现伤害
				ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
				--返回中弹标记，出发中弹效果
				return 1
			end
		else--相同队伍的触碰    	 
			 --不搜索自己，标签为子弹
			if shoot ~= unit and shootLable == lable then			
				--fireStormFlag:标记该aoe是否已经起作用
				if unit.shootPowerFlag == nil  then
					reinforceEach(unit,shoot,nil) --加强或削弱运算
					unit.shootPowerFlag = 1;
				end
			end
		end
	end
	return 0
end
function moveShootByBuff(shoot, max_distance, direction, speed, ability, keys, particleID)
	local traveled_distance = 0
	local shootHight = 100
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + direction * 50 + Vector(0,0,shootHight)) --发射高度

	--影响弹道的buff
	local caster = keys.caster
	--local unit = keys.unit
	local speed_up_per_stack = caster.speed_up_per_stack
	local item_bonus_shoot_speed = getShootPower(caster, "item_shoot_speed")--caster.item_bonus_shoot_speed

	if speed_up_per_stack == nil then
		speed_up_per_stack = 0
	end
	if item_bonus_shoot_speed == nil then
		item_bonus_shoot_speed = 0
	end


	local buff_modifier = "modifier_shoot_speed_up_buff"
	local speed_up_stacks = 0
	if caster:HasModifier(buff_modifier) then
		speed_up_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	end
	local buff_speed_up = speed_up_stacks * speed_up_per_stack

	speed = (speed  + buff_speed_up  + item_bonus_shoot_speed) * 0.02
	
	--local duration = ability:GetSpecialValueFor("duration")
	--local caster = keys.caster
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		if traveled_distance < max_distance then
			--shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
			--shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,100)) --发射高度
			local newPos = shoot:GetOrigin() + direction * speed
			FindClearSpaceForUnit( shoot, newPos, false )
			shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,shootHight))
			--shoot:SetAbsOrigin(newPos)
			--判断是否有加强

			if shoot.power_lv > 0 and shoot.power_flag == 1 then
				ParticleManager:DestroyParticle(particleID, true)
				particleID = ParticleManager:CreateParticle(keys.particles_power, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end
			if shoot.power_lv < 0 and shoot.power_flag == 1  then
				ParticleManager:DestroyParticle(particleID, true)
				particleID = ParticleManager:CreateParticle(keys.particles_weak, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end
			traveled_distance = traveled_distance + speed
			--子弹命中目标
			local isHit = shootHit(shoot, keys)		
			--获得子弹法魂是否为0
			local isHealth = shoot.isHealth--:GetContext("isHealth")

			--击中目标
			if isHit == 1 then
			
				local destroyParticleID = particleID
				local showParticlesName = keys.particles_hit
				local soundName = keys.sound_hit
				particleOperation(shoot,destroyParticleID,showParticlesName,soundName,0.7)

				return nil
			end

			--法魂被击破
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
				shoot:ForceKill(true)
				shoot:AddNoDraw()
				return nil
			end
		end
      return 0.02
     end,0)
end
]]
--[[
--以下只为兼容旧代码存在，以后没用
function moveShoot(shoot, max_distance, direction, speed, ability, keys, particleID)
	local traveled_distance = 0
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + direction * 50 + Vector(0,0,100)) --发射高度
	--local duration = ability:GetSpecialValueFor("duration")
	--local caster = keys.caster
	speed = speed *0.02
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		if traveled_distance < max_distance then
			--shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
			--shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,100)) --发射高度
			local newPos = shoot:GetOrigin() + direction * speed
			FindClearSpaceForUnit( shoot, newPos, false )
			shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,100))
			--shoot:SetAbsOrigin(newPos)
			--判断是否有加强
			
			if shoot.power_lv > 0 and shoot.power_flag == 1 then
				ParticleManager:DestroyParticle(particleID, true)
				particleID = ParticleManager:CreateParticle(keys.particles_power, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end
			if shoot.power_lv < 0 and shoot.power_flag == 1  then
				ParticleManager:DestroyParticle(particleID, true)
				particleID = ParticleManager:CreateParticle(keys.particles_weak, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end

			traveled_distance = traveled_distance + speed
			local isHit = shootHit(shoot, keys)
			
			-- 命中目标
			if isHit == 1 then
				--中弹粒子效果
				ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
				--中弹声音
				EmitSoundOn(keys.sound_hit, shoot)

				--消除粒子效果
				if particleID then
					ParticleManager:DestroyParticle(particleID, true)
				end

				--消除子弹以及中弹粒子效果
				shoot:ForceKill(true)
				GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function () shoot:AddNoDraw() end, 0.7)--keys.particles_hit_dur) --命中后动画持续时间

				return nil
			end
		else
			--超出射程没有命中
			if shoot then
				
				if particleID then
					ParticleManager:DestroyParticle(particleID, true)
				end			
				shoot:ForceKill(true)
				shoot:AddNoDraw()
				
				return nil
			end
		end
      return 0.02
     end,0)
end]]
