require('shoot_init')
require('skill_operation')
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


		local speed = shoot_speed
		--local traveled_distance = 0
		--local point = ability:GetCursorPosition()

		--local starting_distance = ability:GetLevelSpecialValueFor( "starting_distance", ability:GetLevel() - 1 )
		local direction = (ability:GetCursorPosition() - caster:GetAbsOrigin()):Normalized()
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
		--unitModel = shootUnit
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
		creatSkillShootInit(keys,shoot,caster)
		

		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)
		moveShoot(keys, shoot, max_distance, direction, speed, particleID, shootBoom, nil)
	else
		keys.ability:RefundManaCost()
	end
end

--充能用的冷却，每个技能需要独立一个字段使用，caster下的弹夹需要是唯一的
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


function shootBoom(keys,shoot,particleID)
	local ability = keys.ability
	local damage = getApplyDamageValue(keys,shoot)
	for i = 1, #shoot.hitUnits  do
		local unit = shoot.hitUnits[1]
		ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})	
	end
	if particleID ~= nil then
		ParticleManager:DestroyParticle(particleID, true)
	end
	shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit,keys.particles_hit_dur)
end


