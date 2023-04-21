require('shoot_init')
require('skill_operation')
function createStoneSpear(keys)
		local caster = keys.caster
		local ability = keys.ability
        --local player = caster:GetPlayerOwnerID()
		local speed = ability:GetSpecialValueFor("speed")
		local max_distance = ability:GetSpecialValueFor("max_distance")
		local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
		local position = caster:GetAbsOrigin()
		local direction = (ability:GetCursorPosition() - position):Normalized()
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
        --shoot:SetControllableByPlayer(player, true)
        shoot:SetForwardVector(direction)
		
        local casterBuff = keys.modifier_caster_name
		local flyDuration = max_distance / speed * 1.65
        ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = flyDuration})

		local ability_a_name	= keys.ability_a_name
		local ability_b_name	= keys.ability_b_name
		caster:SwapAbilities( ability_a_name, ability_b_name, false, true )
        
        creatSkillShootInit(keys,shoot,caster)
		initDurationBuff(keys)
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		moveShoot(keys, shoot, max_distance, direction, particleID, stoneSpearHitCallBack, nil)

		local timeCount = 0
		local interval = 0.1


		caster:SetContextThink( DoUniqueString( "updateStoneSpear" ), function ( )
		--GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"), function ()
			-- Interrupted
			if not caster:HasModifier( casterBuff ) then
				return nil
			end
			--朝向为0-360
			local shootAngles = shoot:GetAnglesAsVector().y
			local casterAngles	= caster:GetAnglesAsVector().y
			local Steering = 1
			if shootAngles ~= casterAngles then
				local resultAngle = casterAngles - shootAngles
                resultAngle = math.abs(resultAngle)
                if resultAngle > 180 then
                    if shootAngles < casterAngles then
						Steering = -1
					end
				else
					if shootAngles > casterAngles then
						Steering = -1
					end
                end
				local currentDirection =  shoot:GetForwardVector()
				
				local newX2 = math.cos(math.atan2(currentDirection.y, currentDirection.x) + angleRate * Steering)
				local newY2 = math.sin(math.atan2(currentDirection.y, currentDirection.x) + angleRate * Steering)
				local tempDirection = Vector(newX2, newY2, currentDirection.z)
				shoot:SetForwardVector(tempDirection)
				shoot.direction = tempDirection
			end

			if timeCount < flyDuration then
				timeCount = timeCount + interval
				return interval
			else
				return nil
			end
		end, 0)
end

function stoneSpearHitCallBack(keys,shoot,particleID)
    local ability = keys.ability
	local damage = getApplyDamageValue(shoot)
	for i = 1, #shoot.hitUnits  do
		local unit = shoot.hitUnits[1]
		ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})	
	end
	if particleID ~= nil then
		ParticleManager:DestroyParticle(particleID, true)
	end
	shootBoomParticleOperation(shoot,particleID,keys.particles_hit,keys.sound_hit,keys.particles_hit_dur)
	EndStoneSpear( keys )
end

function initSkillStage(keys)
	local caster = keys.caster
	local ability = keys.ability
	-- Swap main ability
	local ability_a_name = keys.ability_a_name
	local ability_b_name = keys.ability_b_name
	caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
	--caster:InterruptMotionControllers( true )
end

function EndStoneSpear( keys )
	--initSkillStage(keys)
	local caster = keys.caster
	caster:RemoveModifierByName( keys.modifier_caster_name )
end



function CheckToInterrupt( keys )
	local caster = keys.caster
	if caster:IsStunned() or caster:IsHexed() or caster:IsFrozen() or caster:IsNightmared() or caster:IsOutOfGame() then
		-- Interrupt the ability
		EndStoneSpear(keys)
	end
end


function LevelUpAbility(keys)
    local caster = keys.caster
	local this_ability = keys.ability
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_b_name = keys.ability_b_name
	local ability_handle = caster:FindAbilityByName(ability_b_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end


function OnOrder(keys)
	local caster = keys.caster
	local ability = keys.ability
	--print("GetCursorPosition",caster:GetCursorPosition())
end