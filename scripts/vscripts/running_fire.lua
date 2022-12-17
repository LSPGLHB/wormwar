function shootStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = "modifier_running_fire_counter_datadriven"
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	caster.running_fire_max_charges = maximum_charges
	caster.running_fire_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.running_fire_charges == nil then
		caster.running_fire_cooldown = 0.0
		caster.running_fire_charges = maximum_charges
	else
		local lastmax_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 2 ) )
		caster.running_fire_charges = caster.running_fire_charges + maximum_charges - lastmax_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.running_fire_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then	
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
		caster.running_fire_start_charge = false
		createCharges(keys)	
	end
end

--启动上弹直到满弹
function createCharges(keys)

	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = "modifier_running_fire_counter_datadriven"

	Timers:CreateTimer(function()
		-- Restore charge
		if caster.running_fire_start_charge and caster.running_fire_charges < caster.running_fire_max_charges then
			local next_charge = caster.running_fire_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.running_fire_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.running_fire_charge_replenish_time } )
				shoot_start_cooldown( caster, caster.running_fire_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.running_fire_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.running_fire_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.running_fire_charges < caster.running_fire_max_charges then
			caster.running_fire_start_charge = true
			return caster.running_fire_charge_replenish_time
		else
			caster.running_fire_start_charge = false
			return nil
		end
	end)

end



function createShoot(keys)
	if keys.caster.running_fire_charges > 0 then
		local caster = keys.caster
		local ability = keys.ability
	
		local shoot_speed = ability:GetLevelSpecialValueFor("speed", ability:GetLevel() - 1)
		local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel() - 1)

		local speed = shoot_speed 
		local traveled_distance = 0
		--local point = ability:GetCursorPosition()

		--local starting_distance = ability:GetLevelSpecialValueFor( "starting_distance", ability:GetLevel() - 1 )
		--local direction = caster:GetForwardVector()
		local position = caster:GetAbsOrigin() --+ starting_distance * direction

		local counterModifierName = "modifier_running_fire_counter_datadriven"
		local maximum_charges = caster.running_fire_max_charges
		local charge_replenish_time = caster.running_fire_charge_replenish_time
		local next_charge = caster.running_fire_charges - 1

		--满弹情况下开枪启动充能
		if caster.running_fire_charges == maximum_charges then
			caster:RemoveModifierByName( counterModifierName )
			ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
			createCharges(keys)
			shoot_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( counterModifierName, caster, next_charge )
		caster.running_fire_charges = next_charge
		--无弹后启动技能冷却
		if caster.running_fire_charges == 0 then
			ability:StartCooldown( caster.running_fire_cooldown )
		else
			ability:EndCooldown()
		end
		
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_running_fire_open_datadriven", {})

		local shoot = {}
		local fireConut = 0

		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
		function ()
			shoot[fireConut] = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
			shoot[fireConut]:SetOwner(caster)
			shoot[fireConut].power_lv = 0
			shoot[fireConut].power_flag = 0
			local particleID = ParticleManager:CreateParticle(keys.particles1, PATTACH_ABSORIGIN_FOLLOW , shoot[fireConut]) 
			moveShoot(shoot[fireConut], traveled_distance, max_distance, speed, ability, keys, particleID)
			fireConut = fireConut + 1
			if fireConut < 5 then
				return 0.5
			else
				return nil
			end
			
		end,0)
	
	else
		keys.ability:RefundManaCost()
	end	
end

--子弹移动
function moveShoot(shoot, traveled_distance, max_distance, speed, ability, keys, particleID)
	local caster = keys.caster
	local direction = caster:GetForwardVector()

	speed = speed * 0.02
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,100)) --发射高度
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		local shootHp = shoot:GetHealth()--判断子弹是否被消灭
		if traveled_distance < max_distance and shootHp > 0 then
			--shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
			--shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,100)) --发射高度
			local newPos = shoot:GetOrigin() + direction * speed
			FindClearSpaceForUnit( shoot, newPos, false )
			shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,100))
			--shoot:SetAbsOrigin(newPos)
			--判断是否有加强
			if shoot.power_lv > 0 and shoot.power_flag == 1 then
				ParticleManager:DestroyParticle(particleID, true)
				particleID = ParticleManager:CreateParticle(keys.particles1plus, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end
			if shoot.power_lv < 0 and shoot.power_flag == 1  then
				ParticleManager:DestroyParticle(particleID, true)
				particleID = ParticleManager:CreateParticle(keys.particles1weak, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end

			traveled_distance = traveled_distance + speed
			local isHit = shootHit(shoot, ability)
			-- 命中目标
			if isHit == 1 then 
				ParticleManager:CreateParticle(keys.particles2, PATTACH_ABSORIGIN_FOLLOW, shoot) --中弹动画
				EmitSoundOn(keys.sound1, shoot)--中弹声音
				shoot:ForceKill(true)
				GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function () shoot:AddNoDraw() end,0.7) --命中后动画持续时间
				return nil
			end
		else
			--超出射程没有命中
			if shoot then 
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

		ApplyDamage({victim = v, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
		
		return 1
	end	
	return 0

end


function shoot_start_cooldown( caster, charge_replenish_time )
	caster.running_fire_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.running_fire_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.running_fire_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end


