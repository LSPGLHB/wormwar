function DealDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_increase = ability:GetLevelSpecialValueFor("damage_increase", ability.level -1)
	local pulses = ability:GetLevelSpecialValueFor("pulses", ability.level -1)
	local radius = ability:GetLevelSpecialValueFor("radius", ability.level -1)
	local duration = ability:GetSpecialValueFor("duration")
	
	-- Instantiates the pulse variable, and increments it on every run
	if ability.pulse == nil then
		ability.pulse = 1
	else
		ability.pulse = ability.pulse + 1
	end
	
	-- Our damage variable that increases on every pulse
	local damage = ability.pulse * damage_increase
	local PosTemp = ability:GetCursorPosition()
	local casterTeam = caster:GetTeam()
	-- Finds all units in the radius and applies the pulse damage
	print("casterTeam:::==="..casterTeam)
	local units = FindUnitsInRadius(caster:GetTeam(),    --teamNumber
									target:GetAbsOrigin(),   --postion
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
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	ability.level = ability:GetLevel()
	ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.particle, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(ability.particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.particle, 2, Vector(radius, radius, 0))
end
