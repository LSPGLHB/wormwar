require('shoot_init')
function shootStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = "modifier_shoot_counter_datadriven"
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	caster.shoot_pro_max_charges = maximum_charges
	caster.shoot_pro_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.shoot_pro_charges == nil then
		caster.shoot_pro_cooldown = 0.0
		caster.shoot_pro_charges = maximum_charges
	else
		local lastmax_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 2 ) )
		caster.shoot_pro_charges = caster.shoot_pro_charges + maximum_charges - lastmax_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.shoot_pro_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then	
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
		caster.shoot_pro_start_charge = false
		createCharges(keys)	
	end
end

--启动上弹直到满弹
function createCharges(keys)

	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = "modifier_shoot_counter_datadriven"

	Timers:CreateTimer(function()
		-- Restore charge
		if caster.shoot_pro_start_charge and caster.shoot_pro_charges < caster.shoot_pro_max_charges then
			local next_charge = caster.shoot_pro_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.shoot_pro_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.shoot_pro_charge_replenish_time } )
				shoot_start_cooldown( caster, caster.shoot_pro_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.shoot_pro_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.shoot_pro_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.shoot_pro_charges < caster.shoot_pro_max_charges then
			caster.shoot_pro_start_charge = true
			return caster.shoot_pro_charge_replenish_time
		else
			caster.shoot_pro_start_charge = false
			return nil
		end
	end)

end



function createShoot(keys)
	if keys.caster.shoot_pro_charges > 0 then
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

		local counterModifierName = "modifier_shoot_counter_datadriven"
		local maximum_charges = caster.shoot_pro_max_charges
		local charge_replenish_time = caster.shoot_pro_charge_replenish_time
		local next_charge = caster.shoot_pro_charges - 1

		--满弹情况下开枪启动充能
		if caster.shoot_pro_charges == maximum_charges then
			caster:RemoveModifierByName( counterModifierName )
			ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
			createCharges(keys)
			shoot_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( counterModifierName, caster, next_charge )
		caster.shoot_pro_charges = next_charge
		--无弹后启动技能冷却
		if caster.shoot_pro_charges == 0 then
			ability:StartCooldown( caster.shoot_pro_cooldown )
		else
			ability:EndCooldown()
		end
		
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
		shoot:SetOwner(caster)
		--此处可以设子弹的被动技能等级
		--local skill_lv = caster:FindAbilityByName("shoot_pro_datadriven"):GetLevel() + 1
		--local shoot_sk = shoot:FindAbilityByName("fire_storm_boom_datadriven")
		--shoot_sk:SetLevel(skill_lv)
		shoot.power_lv = 0
		shoot.power_flag = 0

		local casterPos =  caster:GetOrigin()
		local vDirectionTemp = ability:GetCursorPosition() - casterPos
		local vDirection = ( vDirectionTemp:Normalized() ) * max_distance
		local shootTargetPos = casterPos + vDirection

		local shootOffset = Vector( 0, 0, 96 )
		local particleID = ParticleManager:CreateParticle(keys.particles1, PATTACH_CUSTOMORIGIN , caster)
		ParticleManager:SetParticleAlwaysSimulate( particleID)
		ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin() + shootOffset, true)
		ParticleManager:SetParticleControl( particleID, 1, shootTargetPos + shootOffset )
		ParticleManager:SetParticleControl( particleID, 2, Vector( speed, max_distance, 0 ) )

	
		moveShoot(shoot, max_distance, direction, speed, ability, keys, particleID)
		
	else
		keys.ability:RefundManaCost()
	end	
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
--[[
--子弹移动
function moveShoot(shoot, traveled_distance, max_distance, direction, speed, ability, keys, particleID)
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + direction * 50 + Vector(0,0,100)) --发射高度
	local duration = ability:GetSpecialValueFor("duration")
	local caster = keys.caster
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
			local isHit = shootHit(shoot, ability)
			
			-- 命中目标
			if isHit == 1 then 
				ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) --中弹动画
				ParticleManager:DestroyParticle(particleID, true)
				EmitSoundOn(keys.sound_hit, shoot)

				shoot:ForceKill(true) 
				shoot:AddNoDraw() 
			
				return nil
			end
		else
			--超出射程没有命中
			if shoot then

				ParticleManager:DestroyParticle(particleID, true)


				
				shoot:ForceKill(true) 
				shoot:AddNoDraw() 
				
				return nil
			end
		end
      return 0.02
     end,0)
end

--命中目标
function shootHit(shoot, ability)
	local position=shoot:GetAbsOrigin()
	local powerLv = shoot.power_lv
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
	
		local damage = ability:GetAbilityDamage() + powerLv * 1000
		if damage < 0 then
			damage = 1  --伤害保底
		end
		
		return 1
	end	
	return 0

end

]]


--[[此处用于子弹被动技能触发，暂时废弃

function DealDamage(keys)
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability   -- 这里为什么会有时为空？
	local damage_increase = ability:GetLevelSpecialValueFor("damage_increase", ability:GetLevel() -1)
	local damage_max = ability:GetLevelSpecialValueFor("damage_max", ability:GetLevel() -1)
	local pulses = ability:GetLevelSpecialValueFor("pulses", ability:GetLevel() -1)
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	--local duration = ability:GetSpecialValueFor("duration")
	
	-- Instantiates the pulse variable, and increments it on every run
	if ability.pulse == nil then
		ability.pulse = 1
	else
		ability.pulse = ability.pulse + 1
	end
	
	-- Our damage variable that increases on every pulse
	local damage = damage_max--ability.pulse * damage_increase
	local PosTemp = ability:GetCursorPosition()
	local casterTeam = caster:GetTeam()
	-- Finds all units in the radius and applies the pulse damage

	local units = FindUnitsInRadius(caster:GetTeam(),    --teamNumber
									caster:GetAbsOrigin(),   --postion
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
		ParticleManager:DestroyParticle(ability.particle, true)
		ability.pulse = nil
	end
end

function RenderParticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	ability.level = ability:GetLevel()
	ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(ability.particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.particle, 2, Vector(radius, radius, 0))
end
]]


