require('shoot_init')
require('skill_operation')
function createStoneDoubleTwine(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local casterPoint = caster:GetAbsOrigin() 
    local max_distance =  ability:GetSpecialValueFor("max_distance")
    local casterDirection = (skillPoint- caster:GetAbsOrigin()):Normalized()
    local angle23 = 0.5 * math.pi
    local newX2 = math.cos(math.atan2(casterDirection.y, casterDirection.x) - angle23)
    local newY2 = math.sin(math.atan2(casterDirection.y, casterDirection.x) - angle23)
    local newX3 = math.cos(math.atan2(casterDirection.y, casterDirection.x) + angle23)
    local newY3 = math.sin(math.atan2(casterDirection.y, casterDirection.x) + angle23)
    local direction2 = Vector(newX2, newY2, casterDirection.z)
    --table.insert(directionTable,direction2)
    local direction3 = Vector(newX3, newY3, casterDirection.z)
    --table.insert(directionTable,direction3)
    local shootPos2 = casterPoint + direction2 * 200
    local shootPos3 = casterPoint + direction3 * 200
    local shootPos ={}
    table.insert(shootPos,shootPos2)
    table.insert(shootPos,shootPos3)

    

    for i = 1, 2, 1 do
        local shoot = CreateUnitByName(keys.unitModel, shootPos[i], true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster)
        local tempDirection =  (skillPoint - shootPos[i]):Normalized()
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", shoot:GetAbsOrigin(), true)
        moveShoot(keys, shoot, max_distance, tempDirection, speed, particleID, stoneDoubleTwineBoom, nil)
    end
   


end


function stoneDoubleTwineBoom(keys,shoot,particleID)
    local caster = keys.caster
	local ability = keys.ability
    local duration = ability:GetSpecialValueFor("duration") --debuff持续时间
	local damage = getApplyDamageValue(keys,shoot)
	for i = 1, #shoot.hitUnit  do
		local unit = shoot.hitUnit[i]
		ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
        local tempModifier = unit:FindModifierByName(keys.modifierDebuffName)
        if tempModifier ~= nil then
            duration = duration * 2
        end
        ability:ApplyDataDrivenModifier(caster, unit, keys.modifierDebuffName, {Duration = duration})
	end
	if particleID ~= nil then
		ParticleManager:DestroyParticle(particleID, true)
	end
	shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit,0.7)
end