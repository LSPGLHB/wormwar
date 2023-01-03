require('items_power')
function shootHit(shoot, keys, particleID)
	local caster = keys.caster
	local ability = keys.ability
	local position=shoot:GetAbsOrigin()
	local powerLv = shoot.power_lv
	local casterTeam = caster:GetTeam()
	--[[local PlayerID = caster:GetPlayerID()
	PlayerResource:GetTeam(PlayerID)
	print("team========:"..team)
	print("goodguy2:"..DOTA_TEAM_GOODGUYS)
	print("badguy3:"..DOTA_TEAM_BADGUYS)
	print("noteam5:"..DOTA_TEAM_NOTEAM)
	print("CUSTOM_1=6:"..DOTA_TEAM_CUSTOM_1)
	print("CUSTOM_2=7:"..DOTA_TEAM_CUSTOM_2)
	]]
	
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
--[[另类搜索，无用代码
    local aroundEnemyTeamUnit=FindUnitsInRadius(enemyTeam, 
										position,
										nil,
										searchRadius,
										DOTA_UNIT_TARGET_TEAM_FRIENDLY,
										DOTA_UNIT_TARGET_ALL,
										DOTA_UNIT_TARGET_FLAG_NONE,
										FIND_ANY_ORDER,
										false)	
	if #aroundNoTeamUnit > 0 then
		print("aroundNoTeamUnit")						
	end
	if #aroundEnemyTeamUnit > 0 then
		print("aroundEnemyTeamUnit")						
	end							
	if #aroundEnemyTeamUnit > 0 then
		for k,v in pairs(aroundEnemyTeamUnit) do 
			aroundNoTeamUnit[k] = v 
		end 
	end
	]]	
	
	for k,unit in pairs(aroundUnits) do
		local name = unit:GetContext("name")
		local lable =unit:GetUnitLabel()
		local shootLable = "shootLabel"
		local unitTeam = unit:GetTeam()
		local unitType = unit:GetContext("unitType")

		local unitHealth = unit:GetContext("isHealth")
		local shootHealth = shoot:GetContext("isHealth")
		

		--print("unitType:",unitType)
		
		--local isHero= unit:IsHero()
		--此处可判断类型
		--实现伤害
		--此处有问题？？
		local damage = ability:GetLevelSpecialValueFor( "damage" , ability:GetLevel() - 1) 
		if damage == nil then
			damage = ability:GetAbilityDamage()
		end

		local item_bonus_damage = getShootPower(caster, "item_damage")--caster.item_bonus_damage
		if item_bonus_damage == nil then
			item_bonus_damage = 0
		end
	
		damage = damage + powerLv * 1000 + item_bonus_damage
		if damage < 0 then
			damage = 1  --伤害保底
		end
		print("shootHealth:",shootHealth)
		print("unitHealth:",unitHealth)
		--遇到敌人实现伤害并返回撞击反馈
		if(casterTeam ~= unitTeam and shootHealth ~= "0") then
			
			if(shootLable == lable and unitHealth ~= "0") then --碰到的是子弹
				local tempHealth = shoot:GetHealth() - unit:GetHealth()
				print("tempHealth:",tempHealth)
				if(tempHealth > 0) then



					shoot:SetHealth(tempHealth)
					unit:SetHealth(0)
					unit:SetContext("isHealth","0",0)

					ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, unit) 
					EmitSoundOn(keys.sound_hit, unit)
					unit:ForceKill(true)
					GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function () unit:AddNoDraw() end, 0.7)--keys.particles_hit_dur) --命中后动画持续时间

					return 0
				else
					if tempHealth == 0 then
						print("tempHealth:======00")

						unit:SetContext("isHealth","0",0) 
						ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, unit) 
						EmitSoundOn(keys.sound_hit, unit)
						unit:ForceKill(true)
						GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function () unit:AddNoDraw() end, 0.7)--keys.particles_hit_dur) --命中后动画持续时间
					end

					shoot:SetHealth(0)
					shoot:SetContext("isHealth","0",0)
					tempHealth = tempHealth * -1
					unit:SetHealth(tempHealth)
					
					ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
					EmitSoundOn(keys.sound_hit, shoot)
					if particleID then
						ParticleManager:DestroyParticle(particleID, true)
					end
					shoot:ForceKill(true)
					GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function () shoot:AddNoDraw() end, 0.7)--keys.particles_hit_dur) --命中后动画持续时间
					return 1
				end

			else
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

				ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

				return 1
			end
			
			
			
			
		else--相同队伍的触碰
			if shootType ~= nil and shoot ~= unit and shootLable == lable then
				print("shootType:",shootType)
			end
		end  

	end	
	return 0

end

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


function moveShootByBuff(shoot, max_distance, direction, speed, ability, keys, particleID)
	local traveled_distance = 0
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + direction * 50 + Vector(0,0,100)) --发射高度

	--影响弹道的buff
	local caster = keys.caster
	local unit = keys.unit
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
			
			local isHit = shootHit(shoot, keys, particleID)
			
			-- 命中目标
			local isHealth = shoot:GetContext("isHealth")
			
			if isHit == 1 then
				return nil
			end

			if isHealth ==0 then
				if shoot then
				
					if particleID then
						ParticleManager:DestroyParticle(particleID, true)
					end			
					shoot:ForceKill(true)
					shoot:AddNoDraw()
					
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
end
