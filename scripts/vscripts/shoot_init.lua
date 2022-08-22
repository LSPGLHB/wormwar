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
				--ParticleManager:DestroyParticle(particleID, true)
				--particleID = ParticleManager:CreateParticle(keys.particles1plus, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end
			if shoot.power_lv < 0 and shoot.power_flag == 1  then
				--ParticleManager:DestroyParticle(particleID, true)
				--particleID = ParticleManager:CreateParticle(keys.particles1weak, PATTACH_ABSORIGIN_FOLLOW , shoot)
				shoot.power_flag = 0
			end

			traveled_distance = traveled_distance + speed
			local isHit = shootHit(shoot, ability)
			
			-- 命中目标
			if isHit == 1 then 
				ParticleManager:CreateParticle(keys.particles2, PATTACH_ABSORIGIN_FOLLOW, shoot) --中弹动画

				--EmitSoundOn(keys.sound1, shoot)--中弹声音
				--shoot:AddNewModifier( caster, ability, "modifier_fire_storm_datadriven", { duration = duration } )
				--shoot:ApplyDataDrivenThinker( caster, ability, "modifier_fire_storm_datadriven", { duration = duration } ) 

				ParticleManager:DestroyParticle(particleID, true)

				--RenderParticles(keys,shoot)
				--shoot:AddNewModifier( caster, ability, "modifier_fire_storm_datadriven", nil)
				EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)

				shoot:ForceKill(true) 
				shoot:AddNoDraw() 
				
				return nil
			end
		else
			--超出射程没有命中
			if shoot then
				--shoot:ApplyDataDrivenThinker( caster, ability, "modifier_fire_storm_datadriven", { duration = duration } ) 
				--shoot:AddNewModifier( caster, ability, "modifier_fire_storm_datadriven", { duration = duration } )
				ParticleManager:DestroyParticle(particleID, true)

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