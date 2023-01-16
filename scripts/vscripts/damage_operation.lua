--LinkLuaModifier( "modifier_stone_beat_back_aoe_lua", "abilities/modifier_stone_beat_back_aoe_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
----伤害计算(keys, 子弹实体)
function getApplyDamageValue(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local powerLv = shoot.power_lv
	local damage = ability:GetLevelSpecialValueFor( "damage" , ability:GetLevel() - 1) 
	if damage == nil then
		damage = ability:GetAbilityDamage()
	end
	local item_bonus_damage = getShootPower(caster, "item_damage")--caster.item_bonus_damage
	if item_bonus_damage == nil then
		item_bonus_damage = 0
	end
	if powerLv > 0 then
		damage = damage * 1.25
	end
	if powerLv < 0 then
		damage = damage * 0.75
	end
	damage = damage + item_bonus_damage 
	if damage < 0 then
		damage = 0  --伤害保底
	end
	return damage
end

--power_lv：标记增强等级
--power_flag: 标记是否实现增强效果
--加强削弱运算(被搜索目标实体，自身实体，aoe类型)
function reinforceEach(unit,shoot,aoeType)
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
		if unitType == "lei" then
			unit.power_lv =  unit.power_lv - 1
			unit.power_flag = 1
		end
		if unitType == "tu" then
			unit.power_lv =  unit.power_lv + 1
			unit.power_flag = 1
		end
 	end

	if shootType == "feng" then
		if unitType == "tu" then
			unit.power_lv =  unit.power_lv - 1
			unit.power_flag = 1
		end
		if unitType == "huo" then
			unit.power_lv =  unit.power_lv + 1
			unit.power_flag = 1
		end
	end

	if shootType == "shui" then
		if unitType == "huo" then
			unit.power_lv =  unit.power_lv - 1
			unit.power_flag = 1
		end
		if unitType == "feng" then
			unit.power_lv =  unit.power_lv + 1
			unit.power_flag = 1
		end
	end

	if shootType == "lei" then
		if unitType == "feng" then
			unit.power_lv =  unit.power_lv - 1
			unit.power_flag = 1
		end
		if unitType == "shui" then
			unit.power_lv =  unit.power_lv + 1
			unit.power_flag = 1
		end
	end

	if shootType == "tu" then
		if unitType == "shui" then
			unit.power_lv =  unit.power_lv - 1
			unit.power_flag = 1
		end
		if unitType == "lei" then
			unit.power_lv =  unit.power_lv + 1
			unit.power_flag = 1
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


function particleOperation(shoot,destroyParticleID,showParticlesName,soundName,particlesDur)
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




