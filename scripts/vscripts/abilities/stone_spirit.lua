require('shoot_init')
function stoneSpiritStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	caster.stone_spirit_max_charges = maximum_charges
	caster.stone_spirit_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.stone_spirit_charges == nil then
		caster.stone_spirit_cooldown = 0.0
		caster.stone_spirit_charges = maximum_charges
	else
		local lastmax_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 2 ) )
		caster.stone_spirit_charges = caster.stone_spirit_charges + maximum_charges - lastmax_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.stone_spirit_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
		caster.stone_spirit_start_charge = false
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
		if caster.stone_spirit_start_charge and caster.stone_spirit_charges < caster.stone_spirit_max_charges then
			local next_charge = caster.stone_spirit_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.stone_spirit_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.stone_spirit_charge_replenish_time } )
				stone_spirit_start_cooldown( caster, caster.stone_spirit_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.stone_spirit_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.stone_spirit_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.stone_spirit_charges < caster.stone_spirit_max_charges then
			caster.stone_spirit_start_charge = true
			return caster.stone_spirit_charge_replenish_time
		else
			caster.stone_spirit_start_charge = false
			return nil
		end
	end)

end



function createStoneSpirit(keys)
	if keys.caster.stone_spirit_charges > 0 then
		local caster = keys.caster
		local ability = keys.ability
	
		local stone_spirit_speed = ability:GetLevelSpecialValueFor("speed_min", ability:GetLevel() - 1)
		local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel() - 1)


		local speed = stone_spirit_speed
		--local traveled_distance = 0
		--local point = ability:GetCursorPosition()

		--local starting_distance = ability:GetLevelSpecialValueFor( "starting_distance", ability:GetLevel() - 1 )
		local direction = caster:GetForwardVector()
		local position = caster:GetAbsOrigin() --+ starting_distance * direction

		local counterModifierName = keys.modifierCountName
		local maximum_charges = caster.stone_spirit_max_charges
		local charge_replenish_time = caster.stone_spirit_charge_replenish_time
		local next_charge = caster.stone_spirit_charges - 1

		--满弹情况下开枪启动充能
		if caster.stone_spirit_charges == maximum_charges then
			caster:RemoveModifierByName( counterModifierName )
			ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
			createCharges(keys)
			stone_spirit_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( counterModifierName, caster, next_charge )
		caster.stone_spirit_charges = next_charge
		--无弹后启动技能冷却
		if caster.stone_spirit_charges == 0 then
			ability:StartCooldown( caster.stone_spirit_cooldown )
		else
			ability:EndCooldown()
		end
		--unitModel = shootUnit
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
		shoot:SetOwner(caster)
		shoot.unit_type = keys.unitType
		shoot.power_lv = 0
		shoot.power_flag = 0

		local cp = keys.cp
		if cp == nil then
			cp = 0
		end
		
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, cp , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)
		moveShoot(shoot, max_distance, direction, speed, keys, particleID)	
	else
		keys.ability:RefundManaCost()
	end
end

--充能用的冷却，每个技能需要独立一个字段使用，caster下的弹夹需要是唯一的
function stone_spirit_start_cooldown( caster, charge_replenish_time )
	caster.stone_spirit_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.stone_spirit_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.stone_spirit_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end





