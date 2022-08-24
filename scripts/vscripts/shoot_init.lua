function moveShoot(shoot, max_distance, direction, speed, ability, keys, particleID)
	local traveled_distance = 0
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
		
				shoot.power_flag = 0
			end
			if shoot.power_lv < 0 and shoot.power_flag == 1  then
		
				shoot.power_flag = 0
			end

			traveled_distance = traveled_distance + speed
			local isHit = shootHit(shoot, ability)
			
			-- 命中目标
			if isHit == 1 then
				
				ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) --中弹动画

				EmitSoundOn(keys.sound_hit, shoot)--中弹声音
				--shoot:AddNewModifier( caster, ability, "modifier_fire_storm_datadriven", { duration = duration } )
				--shoot:ApplyDataDrivenThinker( caster, ability, "modifier_fire_storm_datadriven", { duration = duration } ) 

				if particleID then
					ParticleManager:DestroyParticle(particleID, true)
				end

				--RenderParticles(keys,shoot)
				--shoot:AddNewModifier( caster, ability, "modifier_fire_storm_datadriven", nil)
				EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)

				shoot:ForceKill(true) 
				GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function () shoot:AddNoDraw() end,0.7) --命中后动画持续时间

				
			
				
				return nil
			end
		else
			--超出射程没有命中
			if shoot then
				--shoot:ApplyDataDrivenThinker( caster, ability, "modifier_fire_storm_datadriven", { duration = duration } ) 
				--shoot:AddNewModifier( caster, ability, "modifier_fire_storm_datadriven", { duration = duration } )
				if particleID then
					ParticleManager:DestroyParticle(particleID, true)
				end
			

				--RenderParticles(keys,shoot)
				--shoot:AddNewModifier( caster, ability, "modifier_fire_storm_datadriven", nil)
				EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)
				
				shoot:ForceKill(true) 
				shoot:AddNoDraw() 
				
				return nil
			end
		end
      return 0.02
     end,0)
end

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
		--此处有问题
		--local damage = ability:GetAbilityDamage()
		--if damage == nil then
			damage = ability:GetLevelSpecialValueFor( "damage" , ability:GetLevel() - 1) 
		--end
		
		damage = damage + powerLv * 100
		if damage < 0 then
			damage = 1  --伤害保底
		end
	
		ApplyDamage({victim = v, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
		
		return 1
	end	
	return 0

end