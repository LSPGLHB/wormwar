modifier_rattletrap_hookshot_lua = class({})
--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_lua:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_lua:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_lua:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_lua:OnCreated( kv )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_lua:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_lua:CheckState()
	if IsServer() then
		if self:GetCaster() ~= nil and self:GetParent() ~= nil then
			if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
				local state = {
				[MODIFIER_STATE_STUNNED] = true,
				}

				return state
			end
		end
	end

	local state = {}

	return state
end

--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_lua:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		if self:GetAbility().hookshotVictim ~= nil then
			self:GetAbility().hookshotVictim:SetOrigin( self:GetAbility().hookshotProjectileLocation )
			local vToCaster = self:GetAbility().hookshotStartPosition - self:GetCaster():GetOrigin()
			local flDist = vToCaster:Length2D()
			if self:GetAbility().hookshotChainAttached == false and flDist > 128.0 then 
				self:GetAbility().hookshotChainAttached = true  
				ParticleManager:SetParticleControlEnt( self:GetAbility().hookshotChainParticleFXIndex, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN, "attach_hitloc", self:GetCaster():GetOrigin(), true )
				ParticleManager:SetParticleControl( self:GetAbility().hookshotChainParticleFXIndex, 0, self:GetAbility().hookshotStartPosition + self:GetAbility().hookshotHookOffset )
			end                   
		end
	end
end

--------------------------------------------------------------------------------
function modifier_rattletrap_hookshot_lua:OnHorizontalMotionInterrupted()
	if IsServer() then
		if self:GetAbility().hookshotVictim ~= nil then
			ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetAbsOrigin() + self:GetAbility().hookshotHookOffset, true )
			self:Destroy()
		end
	end
end
