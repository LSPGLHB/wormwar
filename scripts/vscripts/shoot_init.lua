function moveShoot(shoot, max_distance, direction, speed, ability, keys, particleID)
	local traveled_distance = 0
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + direction * 50 + Vector(0,0,100)) --发射高度
	--local duration = ability:GetSpecialValueFor("duration")
	--local caster = keys.caster
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
				--中弹粒子效果
				ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
				--中弹声音
				EmitSoundOn(keys.sound_hit, shoot)

				--消除粒子效果
				if particleID then
					ParticleManager:DestroyParticle(particleID, true)
				end

				--消除子弹以及中弹粒子效果
				shoot:ForceKill(true)
				GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function () shoot:AddNoDraw() end, keys.particles_hit_dur) --命中后动画持续时间

				return nil
			end
		else
			--超出射程没有命中
			if shoot then
				
				if particleID then
					ParticleManager:DestroyParticle(particleID, true)
				end			
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
		local damage = ability:GetLevelSpecialValueFor( "damage" , ability:GetLevel() - 1) 
		if damage == nil then
			damage = ability:GetAbilityDamage()
		end
		
		damage = damage + powerLv * 1000
		if damage < 0 then
			damage = 1  --伤害保底
		end
	
		ApplyDamage({victim = v, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
		
		return 1
	end	
	return 0

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