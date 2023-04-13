--LinkLuaModifier( "modifier_stone_beat_back_aoe_lua", "abilities/modifier_stone_beat_back_aoe_lua.lua",LUA_MODIFIER_MOTION_NONE )
----伤害计算(keys, 子弹实体)
function getAbilityShootDamageValue(shoot)
	local damage = powerLevelOperation(shoot.power_lv, shoot.damage) --克制增强运算
	if damage < 0 then
		damage = 0  --伤害保底
	end
	return damage
end
--克制增强运算
function powerLevelOperation(powerLv, damage)
	if powerLv > 0 then
		damage = damage * 1.25
	end
	if powerLv < 0 then
		damage = damage * 0.75
	end
	return damage
end

--power_lv：标记增强等级
--power_flag: 标记是否实现增强效果
--加强削弱运算(被搜索目标实体，自身实体，aoe类型,是否敌对减弱否则加强)
function reinforceEach(unit,shoot,aoeType)
	local shootTeam = shoot:GetTeam()
	local unitTeam = unit:GetTeam()
	local flag
	if shootTeam ~= unitTeam then
		flag = true
	else
		flag = false	
	end
	--获取触碰双方的属性
	local unitType = unit.unit_type
	local shootType
	if shoot ~= nil then
		shootType = shoot.unit_type
	end
	if aoeType ~=nil then
		shootType = aoeType
	end
	--print("shoot-nuit-Type:",shootType,unitType)
	if shootType == "huo" then
		if flag then
			if unitType == "lei" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
			end
		else
			if unitType == "tu" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
			end
		end
 	end
	if shootType == "feng" then
		if flag then
			if unitType == "tu" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
			end
		else
			if unitType == "huo" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
			end
		end
	end
	if shootType == "shui" then
		if flag then
			if unitType == "huo" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
			end
		else
			if unitType == "feng" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
			end
		end
	end
	if shootType == "lei" then
		if flag then
			if unitType == "feng" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
			end
		else
			if unitType == "shui" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
			end
		end
	end
	if shootType == "tu" then
		if flag then
			if unitType == "shui" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
			end
		else
			if unitType == "lei" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
			end
		end
	end
	--限制层数为1
	if unit.power_lv > 1 then
		unit.power_lv = 1
	end
	if unit.power_lv < -1 then
		unit.power_lv = -1
	end
end

--获得buff的能力，目前是测试物品lvxie用到
function setShootPower(caster, powerName, isAdd, value)
    initShootPower(caster)
    if( not isAdd ) then
        value = value * -1
    end
    if(powerName == "item_damage") then       
        caster.item_bonus_damage = caster.item_bonus_damage + value 
    end
    if(powerName == "item_shoot_speed") then       
        caster.item_bonus_shoot_speed = caster.item_bonus_shoot_speed + value 
    end 
end

--获得buff的能力，目前是测试物品lvxie用到
function getShootPower(caster, powerName)
    local value
    if(powerName == "item_damage") then       
        value = caster.item_bonus_damage
    end
    if(powerName == "item_shoot_speed") then    
        value = caster.item_bonus_shoot_speed
    end
    return value
end

function initShootPower(caster)
    if caster.item_bonus_damage == nil then
        caster.item_bonus_damage = 0
    end

    if caster.item_bonus_shoot_speed == nil then
        caster.item_bonus_shoot_speed = 0
    end
end

--技能加强或减弱粒子效果实现
function powerShootParticleOperation(keys,shoot,particleID)
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
end

function shootBoomParticleOperation(shoot,destroyParticleID,showParticlesName,soundName,particlesDur)
	--消除子弹以及中弹粒子效果
	shoot:ForceKill(true)
	--中弹粒子效果
	ParticleManager:CreateParticle(showParticlesName, PATTACH_ABSORIGIN_FOLLOW, shoot)
	
	--中弹声音
	EmitSoundOn(soundName, shoot)
	--消除粒子效果
	if destroyParticleID then
		ParticleManager:DestroyParticle(destroyParticleID, true)
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function () shoot:AddNoDraw() end, particlesDur) --命中后动画持续时间
end

function shootPenetrateParticleOperation(keys,shoot)
	--中弹粒子效果
	ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
	--中弹声音
	EmitSoundOn(keys.sound_hit, shoot)
end


--影响弹道的buff
--测试速度调整
function skillSpeedOperation(keys,speed)
	local caster = keys.caster
	local ability = keys.ability
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
	return speed
end




