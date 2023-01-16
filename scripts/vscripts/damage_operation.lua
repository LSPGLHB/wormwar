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
	damage = powerLevelOperation(powerLv, damage)
	damage = damage + item_bonus_damage
	if damage < 0 then
		damage = 0  --伤害保底
	end
	return damage
end

function powerLevelOperation(powerLv, result)
	if powerLv > 0 then
		result = result * 1.25
	end
	if powerLv < 0 then
		result = result * 0.75
	end
	return result
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


--击退单位
function beatBackUnit(keys,shoot,hitTarget,flag)
	local caster = keys.caster
	local ability = keys.ability
	local powerLv = shoot.power_lv
	local beat_back_one = ability:GetSpecialValueFor("beat_back_one")
	local beat_back_speed = ability:GetSpecialValueFor("beat_back_speed")
	local beat_back_two = ability:GetSpecialValueFor("beat_back_two")
	beat_back_one = powerLevelOperation(powerLv, beat_back_one)
	beat_back_two = powerLevelOperation(powerLv, beat_back_two)
	local hitTargetDebuff = keys.hitTargetDebuff
	--hitTarget:AddNewModifier(caster, ability, hitTargetDebuff, {Duration = control_time} )--需要调用lua的modefier
	ability:ApplyDataDrivenModifier(caster, hitTarget, hitTargetDebuff, {Duration = -1})

	if flag == "one" then
		shoot:SetOrigin(shoot:GetOrigin() + Vector(0,0,shoot.shootHight*-1))--把子弹的高度降到0
	end
	local shootPos = shoot:GetAbsOrigin()
	local targetPos = hitTarget:GetAbsOrigin()
	local beatBackDirection =  (targetPos - shootPos):Normalized() --这里不同单位碰撞的结果不一样
	local interval = 0.02
	local speedmod = beat_back_speed * interval
	local bufferTempDis = hitTarget:GetPaddedCollisionRadius()
	local traveled_distance = 0
	--记录击退时间
	local beatTime = GameRules:GetGameTime()
	hitTarget.lastBeatBackTime = beatTime
	local beat_back_distance
	if flag == "one" then
		beat_back_distance = beat_back_one
		
	end
	if flag == "two" then
		beat_back_distance = beat_back_two
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
	function ()
		if traveled_distance < beat_back_distance and beatTime == hitTarget.lastBeatBackTime then --如果击退时间没被更改继续执行
			local newPosition = hitTarget:GetAbsOrigin() + Vector(beatBackDirection.x, beatBackDirection.y, 0) * speedmod
			local tempLastDis = beat_back_distance - traveled_distance
			--中途可穿模，最后不能穿
			if tempLastDis > bufferTempDis then
				hitTarget:SetAbsOrigin(newPosition)
			else
				FindClearSpaceForUnit( hitTarget, newPosition, false )
			end
			traveled_distance = traveled_distance + speedmod

			if flag == "one" then
				checkSecondHit(keys,hitTarget)
			end
		else
			hitTarget:InterruptMotionControllers( true )
			hitTarget:RemoveModifierByName(hitTargetDebuff)		
			hitTarget.stoneBeatBack = 0
			--EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", caster)
			return nil
		end
		return interval
	end,0)
end

--击退的单位二次击退其他单位
function checkSecondHit(keys,shoot)
	local caster = keys.caster
	--local ability = keys.ability
	local position = shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
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

	for k,unit in pairs(aroundUnits) do
		--local name = unit:GetContext("name")
		local lable =unit:GetUnitLabel()
		local shootLable = "shootLabel"
		--local unitTeam = unit:GetTeam()
		if(shootLable ~= lable and shoot ~= unit and unit.stoneBeatBack ~= 1) then --碰到的不是子弹,不是自己,没被该技能碰撞过		
			print("hithithit")
			unit.stoneBeatBack = 1
			beatBackUnit(keys,shoot,unit,"two")
		end

	end

end




