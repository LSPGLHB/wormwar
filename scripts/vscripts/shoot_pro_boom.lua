function shootStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	caster.shoot_pro_boom_max_charges = maximum_charges
	caster.shoot_pro_boom_charge_replenish_time = charge_replenish_time
	
	--子弹数刷新
	if caster.shoot_pro_boom_charges == nil then
		caster.shoot_pro_boom_cooldown = 0.0
		caster.shoot_pro_boom_charges = maximum_charges
	else
		local lastmax_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 2 ) )
		caster.shoot_pro_boom_charges = caster.shoot_pro_boom_charges + maximum_charges - lastmax_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.shoot_pro_boom_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then	
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
		caster.shoot_pro_boom_start_charge = false
		createCharges(keys)	
	end
end

--启动上弹直到满弹
function createCharges(keys)

	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName

	Timers:CreateTimer(function()
		-- Restore charge
		if caster.shoot_pro_boom_start_charge and caster.shoot_pro_boom_charges < caster.shoot_pro_boom_max_charges then
			local next_charge = caster.shoot_pro_boom_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.shoot_pro_boom_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.shoot_pro_boom_charge_replenish_time } )
				shoot_start_cooldown( caster, caster.shoot_pro_boom_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.shoot_pro_boom_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.shoot_pro_boom_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.shoot_pro_boom_charges < caster.shoot_pro_boom_max_charges then
			caster.shoot_pro_boom_start_charge = true
			return caster.shoot_pro_boom_charge_replenish_time
		else
			caster.shoot_pro_boom_start_charge = false
			return nil
		end
	end)

end



function createShoot(keys)
	if keys.caster.shoot_pro_boom_charges > 0 then
		local caster = keys.caster
		local ability = keys.ability
	
		local shoot_speed = ability:GetLevelSpecialValueFor("speed", ability:GetLevel() - 1)
		local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel() - 1)

		local speed = shoot_speed
		local traveled_distance = 0
		--local point = ability:GetCursorPosition()

		--local starting_distance = ability:GetLevelSpecialValueFor( "starting_distance", ability:GetLevel() - 1 )
		local direction = caster:GetForwardVector()
		local position = caster:GetAbsOrigin() --+ starting_distance * direction

		local counterModifierName = keys.modifierCountName
		local maximum_charges = caster.shoot_pro_boom_max_charges
		local charge_replenish_time = caster.shoot_pro_boom_charge_replenish_time
		local next_charge = caster.shoot_pro_boom_charges - 1

		--满弹情况下开枪启动充能
		if caster.shoot_pro_boom_charges == maximum_charges then
			caster:RemoveModifierByName( counterModifierName )
			ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
			createCharges(keys)
			shoot_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( counterModifierName, caster, next_charge )
		caster.shoot_pro_boom_charges = next_charge
		--无弹后启动技能冷却
		if caster.shoot_pro_boom_charges == 0 then
			ability:StartCooldown( caster.shoot_pro_boom_cooldown )
		else
			ability:EndCooldown()
		end
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
		ability.shoot = shoot
		shoot:SetOwner(caster)
		shoot.power_lv = 0
		shoot.power_flag = 0

	
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 


	
		moveShoot(shoot, traveled_distance, max_distance, direction, speed, ability, keys, particleID)
		
	else
		keys.ability:RefundManaCost()
	end	
end

--子弹移动
function moveShoot(shoot, traveled_distance, max_distance, direction, speed, ability, keys, particleID)
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + direction * 50 + Vector(0,0,100)) --发射高度
	local caster = keys.caster
	speed = speed *0.02
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		local shootHp = shoot:GetHealth()--判断子弹是否被消灭

		if traveled_distance < max_distance and shootHp> 0 then
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
			local isHit = shootHit(shoot, ability)
			
			-- 命中目标
			if isHit == 1 then 
				ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) --中弹动画

	
				EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)--中弹声音


				ParticleManager:DestroyParticle(particleID, true)
			
			
				skillBoom(keys,shoot)
				
				return nil
			end
		else
			--超出射程没有命中
			if shoot then

				ParticleManager:DestroyParticle(particleID, true)

				skillBoom(keys,shoot)
		
				return nil
			end
		end
      return 0.02
     end,0)
end

--技能爆炸
function skillBoom(keys,shoot)
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local interval = ability:GetSpecialValueFor("interval")
	local thinkTime = 0
	local caster = keys.caster
	local particleBoom = RenderParticles(keys,shoot) --粒子效果生成

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

--命中目标
function shootHit(shoot, ability)
	local position=shoot:GetAbsOrigin()
	--local powerLv = shoot.power_lv
	--寻找目标
	local aroundUnit=FindUnitsInRadius(DOTA_TEAM_NEUTRALS, 
										position,
										nil,
										100,
										DOTA_UNIT_TARGET_TEAM_FRIENDLY,
										DOTA_UNIT_TARGET_ALL,
										DOTA_UNIT_TARGET_FLAG_NONE,
										FIND_ANY_ORDER,
										false)
	for k,v in pairs(aroundUnit) do
		local lable=v:GetContext("name")
		--local isHero= v:IsHero()
		--此处可判断类型
		--实现伤害
		return 1
	end	
	return 0

end


function shoot_start_cooldown( caster, charge_replenish_time )
	caster.shoot_pro_boom_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.shoot_pro_boom_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.shoot_pro_boom_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end


function DealDamage(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local damage_increase = ability:GetLevelSpecialValueFor("damage_increase", ability.level -1)
	local pulses = ability:GetLevelSpecialValueFor("pulses", ability.level -1)
	local radius = ability:GetLevelSpecialValueFor("radius", ability.level -1)
	
	
	-- Instantiates the pulse variable, and increments it on every run
	if ability.pulse == nil then
		ability.pulse = 1
	else
		ability.pulse = ability.pulse + 1
	end
	
	-- Our damage variable that increases on every pulse
	local damage = ability.pulse * damage_increase
	local casterTeam = caster:GetTeam()
	-- Finds all units in the radius and applies the pulse damage

	local units = FindUnitsInRadius(caster:GetTeam(),    --teamNumber
									shoot:GetAbsOrigin(),   --postion
									nil, 					--cacheUnit
									radius,                 --radius
									DOTA_UNIT_TARGET_TEAM_BOTH,   --teamFilter
									DOTA_UNIT_TARGET_ALL,           --typeFilter
									0,                              --flagFilter
									0,                                --order
									false)                             --canGrowCacge

    for _, unit in ipairs(units) do
		local lable =unit:GetUnitLabel()
		local unitTeam =unit:GetTeam()
		
		if unit.fireStormFlag == nil  then
			if(lable == 'lei') then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
			end
			if (lable == 'mu') then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
			end
			unit.fireStormFlag = 1;
		end
		
		if(casterTeam ~= unitTeam) then
			ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
		end  
    end

	if ability.pulse == pulses then
		
		ability.pulse = nil
	end
end


function RenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	ability.level = ability:GetLevel()
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleBoom, 0, shoot:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(particleBoom, 2, Vector(radius, radius, 0))
	return particleBoom
end




