require('shoot_init')
require('damage_operation')
function createStoneShoot(keys)
		local caster = keys.caster
		local ability = keys.ability
		local speed = ability:GetSpecialValueFor("speed")
		local max_distance = ability:GetSpecialValueFor("max_distance")

        --local beat_back_aoe = ability:GetSpecialValueFor("beat_back_aoe")
        --local beat_back_hero = ability:GetSpecialValueFor("beat_back_hero")
		local direction = caster:GetForwardVector()
		local position = caster:GetAbsOrigin() 
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
		shoot:SetOwner(caster)
		shoot.unit_type = keys.unitType
		shoot.power_lv = 0
		shoot.power_flag = 0
		shoot.hitUnit = {}
		local cp = keys.cp
		if cp == nil then
			cp = 0
		end
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, cp , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)
		moveShootByBuff(shoot, max_distance, direction, speed, ability, keys, particleID)
end

--[[

function shootHit(shoot, keys, hitOver)
	local caster = keys.caster
	local ability = keys.ability
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	--local PlayerID = caster:GetPlayerID() PlayerResource:GetTeam(PlayerID) print("team========:"..team) print("goodguy2:"..DOTA_TEAM_GOODGUYS) print("badguy3:"..DOTA_TEAM_BADGUYS) print("noteam5:"..DOTA_TEAM_NOTEAM) print("CUSTOM_1=6:"..DOTA_TEAM_CUSTOM_1) print("CUSTOM_2=7:"..DOTA_TEAM_CUSTOM_2)
	--寻找目标
	local searchRadius = 100
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										searchRadius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	local isHitUnit = true
	for k,unit in pairs(aroundUnits) do
		--local name = unit:GetContext("name")
		local lable =unit:GetUnitLabel()
		local shootLable = "shootLabel"
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.isHealth--:GetContext("isHealth")
		local shootHealth = shoot.isHealth--:GetContext("isHealth")
		--子弹忽略自己，忽略发射者
		--让子弹跟目标只碰撞一次
		if shoot ~= unit and unit ~= caster then
			for i = 0, #shoot.hitUnit  do
				if shoot.hitUnit [i] == unit then
					isHitUnit = false
					break
				end
			end
			if isHitUnit then
				table.insert(shoot.hitUnit,unit)
			end
		end

		--遇到敌人实现伤害并返回撞击反馈
		if(casterTeam ~= unitTeam and shootHealth ~= 0 and isHitUnit) then --触碰到的不是自家队伍，且自身法魂不为0，是否实现撞击
			--print("shootHealthEEEE:",shootHealth)
			if(shootLable == lable and unitHealth ~= 0) then --碰到的是子弹，且法魂不为0
				--获取触碰双方的属性--print("shoot-nuit-Type:",shoot.unit_type,unit.unit_type)
				--法魂计算过程
				local tempHealth = shoot:GetHealth() - unit:GetHealth()
				if(tempHealth > 0) then
					shoot:SetHealth(tempHealth)
					unit:SetHealth(0)
					unit.isHealth = 0
				else
					if tempHealth == 0 then
						unit.isHealth = 0
					end
					shoot:SetHealth(0)
					shoot.isHealth = 0
					tempHealth = tempHealth * -1
					unit:SetHealth(tempHealth)	
				end
				return 0
			else --碰到的不是子弹
				--撞开击中单位
				beatBackUnit(keys,shoot,unit,"one")
				local damage = getApplyDamageValue(keys,shoot)
				--实现伤害
				ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

				--返回中弹标记，出发中弹效果
				if hitOver == 1 then --爆炸弹
					return 1
				end
				if hitOver == 2 then --穿透弹
					return 2
				end
			end
		else--相同队伍的触碰    	 
			 --不搜索自己，标签为子弹
			if shoot ~= unit and shootLable == lable and isHitUnit then			
				--fireStormFlag:标记该aoe是否已经起作用
				if unit.shootPowerFlag == nil  then
					reinforceEach(unit,shoot,nil) --加强或削弱运算
					unit.shootPowerFlag = 1;
				end
			end
		end
	end
	return 0
end
function moveShootByBuff(shoot, max_distance, direction, speed, ability, keys, particleID)
	local traveled_distance = 0
	shoot.shootHight = 100
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0))--发射方向
	shoot:SetOrigin(shoot:GetOrigin() + direction * 50 + Vector(0,0,shoot.shootHight)) --发射高度
	--影响弹道的buff
	local caster = keys.caster
	--local unit = keys.unit
	local hitOver = keys.hitOver --子弹类型，1：爆炸弹，2：穿透弹
	--默认不可穿透
	if hitOver == nil then
		hitOver = 1
	end
	local speed_up_per_stack = caster.speed_up_per_stack
	local item_bonus_shoot_speed = getShootPower(caster, "item_shoot_speed")--caster.item_bonus_shoot_speed
	if speed_up_per_stack == nil then
		speed_up_per_stack = 0
	end
	if item_bonus_shoot_speed == nil then
		item_bonus_shoot_speed = 0
	end
	local buff_modifier = "modifier_shoot_speed_up_buff"
	local speed_up_stacks = 0
	if caster:HasModifier(buff_modifier) then
		speed_up_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	end
	local buff_speed_up = speed_up_stacks * speed_up_per_stack
	speed = (speed  + buff_speed_up  + item_bonus_shoot_speed) * 0.02
	
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		if traveled_distance < max_distance then
			local newPos = shoot:GetOrigin() + direction * speed
			FindClearSpaceForUnit( shoot, newPos, false )
			shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,shoot.shootHight))
			--shoot:SetAbsOrigin(shoot:GetOrigin()+ Vector(0,0,shoot.shootHight))
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
			--子弹命中目标
			local isHit = shootHit(shoot, keys, hitOver)
			--获得子弹法魂是否为0
			local isHealth = shoot.isHealth--:GetContext("isHealth")
			--击中目标，行程结束
			if isHit == 1 then
				local destroyParticleID = particleID
				local showParticlesName = keys.particles_hit
				local soundName = keys.sound_hit
				particleOperation(shoot,destroyParticleID,showParticlesName,soundName,0.7)
				return nil
			end
			--击中目标，行程继续
			if isHit == 2 then
				--中弹粒子效果
				ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
				--中弹声音
				EmitSoundOn(keys.sound_hit, shoot)

				return 0.02
			end

			--法魂被击破，行程结束
			if isHealth == 0 then
				if shoot then		
					particleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit)
					return nil
				end
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
]]
