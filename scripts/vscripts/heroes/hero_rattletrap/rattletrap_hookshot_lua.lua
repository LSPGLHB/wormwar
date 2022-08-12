rattletrap_hookshot_lua = class({})
LinkLuaModifier( "modifier_rattletrap_hookshot_followthrough_lua", "heroes/hero_rattletrap/modifier_rattletrap_hookshot_followthrough_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rattletrap_hookshot_lua", "heroes/hero_rattletrap/modifier_rattletrap_hookshot_lua.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

--设置技能模型动作
--------------------------------------------------------------------------------

function rattletrap_hookshot_lua:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	return true
end

--------------------------------------------------------------------------------

function rattletrap_hookshot_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

--------------------------------------------------------------------------------
function rattletrap_hookshot_lua:OnSpellStart()

	self.hookshotChainAttached = false
	if self.hookshotVictim ~= nil then
		self.hookshotVictim:InterruptMotionControllers( true )
	end

	self.hookshot_width = self:GetSpecialValueFor("hookshot_width")
	self.hookshot_distance = self:GetSpecialValueFor( "hookshot_distance")
	self.hookshot_speed = self:GetSpecialValueFor( "hookshot_speed")
	self.hookshot_damage = self:GetSpecialValueFor( "hookshot_damage")
	self.hookshot_followthrough_constant = self:GetSpecialValueFor( "followthrough_constant" )

	self.hookshotStartPosition = self:GetCaster():GetOrigin()
	self.hookshotProjectileLocation = self.hookshotStartPosition

	local vDirectionTemp = self:GetCursorPosition() - self.hookshotStartPosition
	vDirectionTemp.z = 0.0

	local vDirection = ( vDirectionTemp:Normalized() ) * self.hookshot_distance   --指定方向的距离
	
	--发射方向的终点
	self.hookshotTargetPosition = self.hookshotStartPosition + vDirection

	--飞钩过程中不能移动
	local flFollowthroughDuration = ( self.hookshot_distance / self.hookshot_speed * self.hookshot_followthrough_constant )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_meat_hook_followthrough_lua", { duration = flFollowthroughDuration } )

	--设置飞行高度
	self.hookshotHookOffset = Vector( 0, 0, 96 )
	--发射方向的终点+高度
	local vHookTarget = self.hookshotTargetPosition + self.hookshotHookOffset

	local vKillswitch = Vector( ( ( self.hookshot_distance / self.hookshot_speed ) * 2 ), 0, 0 )

	self.hookshotChainParticleFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleAlwaysSimulate( self.hookshotChainParticleFXIndex )
	ParticleManager:SetParticleControlEnt( self.hookshotChainParticleFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.hookshotHookOffset, true )
	ParticleManager:SetParticleControl( self.hookshotChainParticleFXIndex, 1, vHookTarget )   
	ParticleManager:SetParticleControl( self.hookshotChainParticleFXIndex, 2, Vector( self.hookshot_speed, self.hookshot_distance, self.hookshot_width ) )  --出钩+链条
	--ParticleManager:SetParticleControl( self.hookshotChainParticleFXIndex, 3, vKillswitch )    --钩子带血
	--ParticleManager:SetParticleControl( self.hookshotChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )   --钩子旋转
	--ParticleManager:SetParticleControl( self.hookshotChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )		--钩子旋转
	ParticleManager:SetParticleControlEnt( self.hookshotChainParticleFXIndex, 6, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

	--发射声音
	EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )
	
	local info = {
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		vVelocity = vDirection:Normalized() * self.hookshot_speed,
		fDistance = self.hookshot_distance,
		fStartRadius = self.hookshot_width ,
		fEndRadius = self.hookshot_width ,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	}

	ProjectileManager:CreateLinearProjectile( info )

	self.hookshotRetracting = false
	self.hookshotVictim = nil
	--self.bDiedInHook = false
	
end

function rattletrap_hookshot_lua:OnProjectileHit( hTarget, vLocation ) --撞击到目标hTarget, 或到达指定位置vLocation（目标无效）
	
	
	StopSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )

	
	--如果目标是自己（发射时碰到自己）
	if hTarget == self:GetCaster() then
		return false
	end
	--技能返回后碰到自己
	if self.hookshotRetracting then
		return false
	end

	--if 目标无效
	if hTarget ~= nil and ( not ( hTarget:IsCreep() or hTarget:IsConsideredHero() ) ) then
		return false
	end

	local hookshotTargetPulled = false
	if hTarget ~= nil then
		EmitSoundOn( "Hero_Pudge.AttackHookImpact", hTarget )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_meat_hook_lua", nil )
		
		--目标不是自己队伍的实现伤害
		if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			local damage = {
					victim = hTarget,
					attacker = self:GetCaster(),
					damage = self.hookshot_damage,
					damage_type = DAMAGE_TYPE_PURE,		
					ability = this
				}

			ApplyDamage( damage )

			
			
			--击中特效
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end

		--AddFOWViewer( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self.vision_radius, self.vision_duration, false )
		self.hookshotVictim = hTarget
		hookshotTargetPulled = true
	end

		
	local vHookPos = self.hookshotTargetPosition   --发射方向的终点
	local flPad = self:GetCaster():GetPaddedCollisionRadius() --碰撞体积半径
	if hTarget ~= nil then
		vHookPos = hTarget:GetOrigin()
		flPad = flPad + hTarget:GetPaddedCollisionRadius()  --双半径叠加
	end

	--Missing: Setting target facing angle 设置目标朝向角度,指向出发点
	local vVelocity = self.hookshotStartPosition - vHookPos
	vVelocity.z = 0.0

	local flDistance = vVelocity:Length2D() - flPad  --两者距离-碰撞半径
	vVelocity = vVelocity:Normalized() * self.hookshot_speed

	local info = {
		Ability = self,
		vSpawnOrigin = vHookPos,  --发射点
		vVelocity = vVelocity,    --速度
		fDistance = flDistance,	  --距离
		Source = self:GetCaster(), --发射者
	}

	ProjectileManager:CreateLinearProjectile( info )   --投射技能
	self.hookshotProjectileLocation = vHookPos          --发射点

	if hTarget ~= nil and ( not hTarget:IsInvisible() ) and hookshotTargetPulled then
		ParticleManager:SetParticleControlEnt( self.hookshotChainParticleFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin() + self.hookshotHookOffset, true )
		ParticleManager:SetParticleControl( self.hookshotChainParticleFXIndex, 4, Vector( 0, 0, 0 ) )
		ParticleManager:SetParticleControl( self.hookshotChainParticleFXIndex, 5, Vector( 1, 0, 0 ) )
		ParticleManager:SetParticleControlEnt( self.hookshotChainParticleFXIndex, 6, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.hookshotHookOffset, true)
	else
		ParticleManager:SetParticleControlEnt( self.hookshotChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.hookshotHookOffset, true)
	end
	
	EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )
	EmitSoundOn( "Hero_Pudge.AttackHookRetract", hTarget )
	

	--动作添加移除
	if self:GetCaster():IsAlive() then
		self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
		self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 )
	end

	self.hookshotRetracting = true

	if self.hookshotVictim ~= nil then
		local caseter  = self:GetCaster()
		local hv = self.hookshotVictim
		local vFinalHookPos = vLocation 
		local vVictimPosCheck = hv:GetOrigin() - vFinalHookPos
		local flPad = self:GetCaster():GetPaddedCollisionRadius() + hv:GetPaddedCollisionRadius()
		if vVictimPosCheck:Length2D() > flPad then
			local backDirectionTemp =  hv:GetAbsOrigin() - self.hookshotStartPosition
			local backDirection =  backDirectionTemp:Normalized()
			local max_distance = backDirectionTemp:Length2D() - flPad * 4
			local traveled_distance = 0
			
			--目标或尽头坐标
			local hookshotPos = vFinalHookPos 

			--FindClearSpaceForUnit( hv, hookPos, false )		
			--钩到目标移动到目标
			GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
				function ()
					if traveled_distance < max_distance then
						local stepSpeed = self.hookshot_speed * 0.02 * 1.5	--动画与模型移动速度比
						local newPosition = caseter:GetAbsOrigin() + backDirection * stepSpeed
						local tempLastDis = max_distance - traveled_distance
						if tempLastDis > flPad then
							caseter:SetAbsOrigin(newPosition)
						else
							FindClearSpaceForUnit( caseter, newPosition, false )
						end
						traveled_distance = traveled_distance + stepSpeed
					else
						hv:InterruptMotionControllers( true )
						--hv:RemoveModifierByName( "modifier_meat_hook_lua" )
						self.hookshotVictim = nil
						ParticleManager:DestroyParticle( self.hookshotChainParticleFXIndex, true )
						StopSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )
						StopSoundOn( "Hero_Pudge.AttackHookRetract", hTarget )
						EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", self:GetCaster() )
						return nil
					end
				return 0.02
				end,0)		
		end
	end

	return true
end

--------------------------------------------------------------------------------

function rattletrap_hookshot_lua:OnProjectileThink( vLocation )
	self.hookshotProjectileLocation = vLocation
end

--------------------------------------------------------------------------------

function rattletrap_hookshot_lua:OnOwnerDied()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
	self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
end

