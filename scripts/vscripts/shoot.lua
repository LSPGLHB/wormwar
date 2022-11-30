require('shoot_init')
function shootStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	caster.shoot_max_charges = maximum_charges
	caster.shoot_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.shoot_charges == nil then
		caster.shoot_cooldown = 0.0
		caster.shoot_charges = maximum_charges
	else
		local lastmax_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 2 ) )
		caster.shoot_charges = caster.shoot_charges + maximum_charges - lastmax_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.shoot_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
		caster.shoot_start_charge = false
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
		if caster.shoot_start_charge and caster.shoot_charges < caster.shoot_max_charges then
			local next_charge = caster.shoot_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.shoot_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.shoot_charge_replenish_time } )
				shoot_start_cooldown( caster, caster.shoot_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.shoot_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.shoot_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.shoot_charges < caster.shoot_max_charges then
			caster.shoot_start_charge = true
			return caster.shoot_charge_replenish_time
		else
			caster.shoot_start_charge = false
			return nil
		end
	end)

end



function createShoot(keys)
	if keys.caster.shoot_charges > 0 then
		local caster = keys.caster
		local ability = keys.ability
	
		local shoot_speed = ability:GetLevelSpecialValueFor("speed", ability:GetLevel() - 1)
		local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel() - 1)

		local speed = shoot_speed * 0.02
		local traveled_distance = 0
		--local point = ability:GetCursorPosition()

		--local starting_distance = ability:GetLevelSpecialValueFor( "starting_distance", ability:GetLevel() - 1 )
		local direction = caster:GetForwardVector()
		local position = caster:GetAbsOrigin() --+ starting_distance * direction

		local counterModifierName = keys.modifierCountName
		local maximum_charges = caster.shoot_max_charges
		local charge_replenish_time = caster.shoot_charge_replenish_time
		local next_charge = caster.shoot_charges - 1

		--满弹情况下开枪启动充能
		if caster.shoot_charges == maximum_charges then
			caster:RemoveModifierByName( counterModifierName )
			ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
			createCharges(keys)
			shoot_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( counterModifierName, caster, next_charge )
		caster.shoot_charges = next_charge
		--无弹后启动技能冷却
		if caster.shoot_charges == 0 then
			ability:StartCooldown( caster.shoot_cooldown )
		else
			ability:EndCooldown()
		end
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
		shoot:SetOwner(caster)
		shoot.power_lv = 0
		shoot.power_flag = 0

		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		--ParticleManager:SetParticleControlEnt(particleID, 0 , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)
		

		moveShootByBuff(shoot, max_distance, direction, speed, ability, keys, particleID)
		
	else
		keys.ability:RefundManaCost()
	end	
end


function shoot_start_cooldown( caster, charge_replenish_time )
	caster.shoot_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.shoot_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.shoot_cooldown = current_cooldown
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
]]




