require('shoot_init')
require('skill_operation')
function createBigFireBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    shoot:SetOwner(caster)
    shoot.unit_type = keys.unitType
    shoot.power_lv = 0
    shoot.power_flag = 0
    local cp = keys.cp
    if cp == nil then
        cp = 0
    end
	--shoot.timer = 0
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, cp , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)

    moveShoot(shoot, max_distance, direction, speed, nil, keys, particleID, bigFireBallBoom)
end


--技能爆炸,单次伤害
function bigFireBallBoom(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失
    local particleBoom = bigFireBallRenderParticles(keys,shoot) --爆炸粒子效果生成		  
    dealSkillBoom(keys,shoot) --实现aoe爆炸效果
    bigFireBallDuration(keys,shoot) --实现持续光环效果
    Timers:CreateTimer(1,function ()
        ParticleManager:DestroyParticle(particleBoom, true)
        EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)
        return nil
    end)
end

function bigFireBallRenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("aoe_boom_radius", ability:GetLevel() -1)
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleBoom, 0, shoot:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 1, radius*2))
    return particleBoom
end



function dealSkillBoom(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("aoe_boom_radius") --AOE爆炸范围
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	for k,unit in pairs(aroundUnits) do
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.isHealth
		local lable = unit:GetUnitLabel()
		--只作用于敌方,非技能单位
		if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
            local beat_back_one = ability:GetSpecialValueFor("beat_back_one")
	        local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed")
            local tempDistance = (shoot:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D()
            local beatBackDistance = beat_back_one - tempDistance   --只击退到AOE的600码
            beatBackUnit(keys,shoot,unit,1,beatBackDistance,beatBackSpeed)
			local damage = getApplyDamageValue(keys,shoot)
			ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
		end
		--如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
		if lable == GameRules.skillLabel and unitHealth ~= 0 then
			reinforceEach(unit,shoot,nil)
		end
	end
end

function bigFireBallDuration(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
    local visionDebuff = keys.modifierDebuffName
    local aoe_duration_radius = ability:GetSpecialValueFor("aoe_duration_radius") --AOE持续作用范围
    local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
    --local vision_radius = ability:GetSpecialValueFor("vision_radius") --视野debuff范围
    local debuff_duration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
    local tempTimer = 0

    local particleBoom = staticStromRenderParticles(keys,shoot)

    Timers:CreateTimer(0,function ()
		local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										aoe_duration_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
        for k,unit in pairs(aroundUnits) do
            local unitTeam = unit:GetTeam()
            local unitHealth = unit.isHealth
            local lable = unit:GetUnitLabel()
            local shootPos = shoot:GetAbsOrigin()
            local unitPos = unit:GetAbsOrigin()
            

            --只作用于敌方,非技能单位
            if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
                ability:ApplyDataDrivenModifier(caster, unit, visionDebuff, {Duration = debuff_duration})
            end
            --如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
            if lable == GameRules.skillLabel and unitHealth ~= 0 then
                reinforceEach(unit,shoot,nil)
            end
        end
        if tempTimer < aoe_duration then
            tempTimer = tempTimer + 0.1
            return 0.1
        else 
            ParticleManager:DestroyParticle(particleBoom, true)
            EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)	
            shoot:ForceKill(true)
            shoot:AddNoDraw()
            return nil
        end
	
	end)
    

end


function staticStromRenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("debuff_duration") --持续时间
	local radius = ability:GetSpecialValueFor("aoe_duration_radius")
	local particleBoom = ParticleManager:CreateParticle(keys.durationParticlesBoom, PATTACH_WORLDORIGIN, caster)
    local shootPos = shoot:GetAbsOrigin()
	ParticleManager:SetParticleControl(particleBoom, 0, Vector(shootPos.x, shootPos.y, shootPos.z + shoot.shootHight))
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 2, Vector(duration, 0, 0))
	return particleBoom
end

