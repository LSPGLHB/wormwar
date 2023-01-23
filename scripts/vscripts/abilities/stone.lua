require('shoot_init')
function createStoneShoot(keys)
		local caster = keys.caster
		local ability = keys.ability
		local speed = ability:GetSpecialValueFor("speed")
		local max_distance = ability:GetSpecialValueFor("max_distance")
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
		moveShoot(shoot, max_distance, direction, speed, keys, particleID)
end

