function cannonStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	caster.cannon_max_charges = maximum_charges
	caster.cannon_charge_replenish_time = charge_replenish_time
	
	--子弹数刷新
	if caster.cannon_charges == nil then
		caster.cannon_cooldown = 0.0
		caster.cannon_charges = maximum_charges
	else
		local lastmax_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 2 ) )
		caster.cannon_charges = caster.cannon_charges + maximum_charges - lastmax_charges
	end
	
	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.cannon_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
		caster.cannon_start_charge = false
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
		if caster.cannon_start_charge and caster.cannon_charges < caster.cannon_max_charges then
			local next_charge = caster.cannon_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.cannon_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.cannon_charge_replenish_time } )
				shoot_start_cooldown( caster, caster.cannon_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.cannon_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.cannon_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.cannon_charges < caster.cannon_max_charges then
			caster.cannon_start_charge = true
			return caster.cannon_charge_replenish_time
		else
			caster.cannon_start_charge = false
			return nil
		end
	end)

end



function createShoot(keys)
	if keys.caster.cannon_charges > 0 then
		local caster = keys.caster
		local ability = keys.ability
	
		local shoot_speed = ability:GetLevelSpecialValueFor("speed", ability:GetLevel() - 1)
		--local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel() - 1)

		local speed = shoot_speed * 0.02
		--local traveled_distance = 0
		local CursorPoint = ability:GetCursorPosition()

		--local starting_distance = ability:GetLevelSpecialValueFor( "starting_distance", ability:GetLevel() - 1 )
		--local direction = caster:GetForwardVector()
		local position = caster:GetAbsOrigin() --+ starting_distance * direction

		local distance = CursorPoint - position

		local ldistance = (distance):Length2D()
		local sDirection = (distance):Normalized() 

		local counterModifierName = keys.modifierCountName
		local maximum_charges = caster.cannon_max_charges
		local charge_replenish_time = caster.cannon_charge_replenish_time
		local next_charge = caster.cannon_charges - 1

		--满弹情况下开枪启动充能
		if caster.cannon_charges == maximum_charges then
			caster:RemoveModifierByName( counterModifierName )
			ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
			createCharges(keys)
			shoot_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( counterModifierName, caster, next_charge )
		caster.cannon_charges = next_charge
		--无弹后启动技能冷却
		if caster.cannon_charges == 0 then
			ability:StartCooldown( caster.cannon_cooldown )
		else
			ability:EndCooldown()
		end
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
		shoot:SetOwner(caster)
		shoot.power_lv = 0
		shoot.power_flag = 0
		ability:ApplyDataDrivenModifier(shoot, shoot, "modifier_cannonball_datadriven", {})
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		--ParticleManager:SetParticleControlEnt(particleID, 0 , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)
		

		moveCannon(shoot, ldistance, sDirection, speed, ability, keys, particleID)
		
	else
		keys.ability:RefundManaCost()
	end	
end


function shoot_start_cooldown( caster, charge_replenish_time )
	caster.cannon_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.cannon_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.cannon_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end

--子弹移动
function moveCannon(shoot, max_distance, direction, speed, ability, keys, particleID)
	local traveled_distance = 0
	local p = 1.6 --抛物线弧度参数，越大越平
	local changshu = (max_distance / 30 / 2) ^ 2 / p + 100
	local zIndex = changshu
	local zStep = 0
	local count =  max_distance / 2 / speed
	local zControl = 0
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		if traveled_distance < max_distance then
			
			zStep = traveled_distance / 30
			
			if traveled_distance > max_distance / 2 then
			
				zControl = zControl + 100 / count
			
			end
			zIndex = - (zStep - (max_distance / 30 / 2)) ^ 2 / p + changshu - zControl
			
			
	
			local newPos = shoot:GetOrigin() + direction * speed
			FindClearSpaceForUnit( shoot, newPos, false )
			shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,zIndex)) --发射高度
			--shoot:SetAbsOrigin(GetGroundPosition(shoot:GetAbsOrigin(), shoot) + Vector(0,0,zIndex))
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
		
		else
			--到达射程
			if shoot then
				ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
				EmitSoundOn(keys.sound_hit, shoot)
				if particleID then
					ParticleManager:DestroyParticle(particleID, true)
				end
                
                skillBoom(keys,shoot,"modifier_boom_storm_datadriven")

				return nil
			end
		end
      return 0.02
     end,0)
end


function skillBoom(keys,shoot,modifierName)
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local interval = ability:GetSpecialValueFor("interval")
	local thinkTime = 0
	local caster = keys.caster
	local particleBoom = RenderParticles(keys,shoot) --粒子效果生成

	ability:ApplyDataDrivenModifier(caster, shoot, modifierName, {})--光环添加

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
		function ()
			DealDamage(keys,shoot)
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



