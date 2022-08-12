pudge_meat_hook_lua = class({})
LinkLuaModifier( "modifier_meat_hook_followthrough_lua", "heroes/hero_pudge/modifiers/modifier_meat_hook_followthrough_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_meat_hook_lua", "heroes/hero_pudge/modifiers/modifier_meat_hook_lua.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

--设置技能模型动作
--------------------------------------------------------------------------------

function pudge_meat_hook_lua:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	return true
end

--------------------------------------------------------------------------------

function pudge_meat_hook_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

--------------------------------------------------------------------------------

function pudge_meat_hook_lua:OnUpgrade()
	self.hook_damage = self:GetLevelSpecialValueFor( "hook_damage" , self:GetLevel() - 1)
	self.hook_speed = self:GetSpecialValueFor( "hook_speed" )
	self.hook_width = self:GetSpecialValueFor( "hook_width" )
	self.hook_distance = self:GetLevelSpecialValueFor( "hook_distance"  , self:GetLevel() - 1)
	self.hook_followthrough_constant = self:GetSpecialValueFor( "hook_followthrough_constant" ) --计算常数
	self.vision_radius = self:GetSpecialValueFor( "vision_radius" )
	self.vision_duration = self:GetSpecialValueFor( "vision_duration" )
end


function pudge_meat_hook_lua:OnSpellStart()

	self.bChainAttached = false
	if self.hVictim ~= nil then
		self.hVictim:InterruptMotionControllers( true )
	end

	self.vStartPosition = self:GetCaster():GetOrigin()
	self.vProjectileLocation = self.vStartPosition

	local vDirectionTemp = self:GetCursorPosition() - self.vStartPosition
	vDirectionTemp.z = 0.0

	local vDirection = ( vDirectionTemp:Normalized() ) * self.hook_distance   --指定方向的距离
	
	--发射方向的终点
	self.vTargetPosition = self.vStartPosition + vDirection

	--飞钩过程中不能移动
	local flFollowthroughDuration = ( self.hook_distance / self.hook_speed * self.hook_followthrough_constant )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_meat_hook_followthrough_lua", { duration = flFollowthroughDuration } )

	--设置飞行高度
	self.vHookOffset = Vector( 0, 0, 96 )
	--发射方向的终点+高度
	local vHookTarget = self.vTargetPosition + self.vHookOffset

	local vKillswitch = Vector( ( ( self.hook_distance / self.hook_speed ) * 2 ), 0, 0 )
--"particles/units/heroes/hero_pudge/pudge_meathook.vpcf"
	self.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/pudge_meathook_test.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleAlwaysSimulate( self.nChainParticleFXIndex )
	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 1, vHookTarget )   
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 2, Vector( self.hook_speed, self.hook_distance, self.hook_width ) )  --出钩+链条
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 3, vKillswitch )    --钩子带血
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )   --钩子旋转
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )		--钩子旋转
	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 6, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

	EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )
	
	local info = {
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		vVelocity = vDirection:Normalized() * self.hook_speed,
		fDistance = self.hook_distance,
		fStartRadius = self.hook_width ,
		fEndRadius = self.hook_width ,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	}

	ProjectileManager:CreateLinearProjectile( info )

	self.bRetracting = false
	self.hVictim = nil
	self.bDiedInHook = false
	
end

--------------------------------------------------------------------------------

function pudge_meat_hook_lua:OnProjectileHit( hTarget, vLocation ) --撞击到目标hTarget, 或到达指定位置vLocation（目标无效）
	
	--print("击中单位")
	StopSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )

	--如果目标是自己（发射时碰到自己）
	if hTarget == self:GetCaster() then
		--print("击中自己")
		return false
	end
	--技能返回后碰到自己
	if self.bRetracting then
		--print("技能返回")
		return false
	end
	--print("去到最远或者碰到目标才继续技能")
	--if self.bRetracting == false then
	--[[
	if hTarget ~= nil and ( not ( hTarget:IsCreep() or hTarget:IsConsideredHero() ) ) then
		--Msg( "Target was invalid")目标无效
		return false
	end]]

	local bTargetPulled = false
	if hTarget ~= nil then
		EmitSoundOn( "Hero_Pudge.AttackHookImpact", hTarget )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_meat_hook_lua", nil )
		
		--目标不是自己队伍的实现伤害
		if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			local damage = {
					victim = hTarget,
					attacker = self:GetCaster(),
					damage = self.hook_damage,
					damage_type = DAMAGE_TYPE_PURE,		
					ability = this
				}

			ApplyDamage( damage )

			if not hTarget:IsAlive() then
				self.bDiedInHook = true
			end

			--是否魔法免疫
			--[[
			if not hTarget:IsMagicImmune() then
				hTarget:Interrupt()
			end]]
			
			--击中特效
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end

		AddFOWViewer( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self.vision_radius, self.vision_duration, false )
		self.hVictim = hTarget
		bTargetPulled = true
	end

		
	local vHookPos = self.vTargetPosition   --发射方向的终点
	local flPad = self:GetCaster():GetPaddedCollisionRadius() --碰撞体积半径
	if hTarget ~= nil then
		vHookPos = hTarget:GetOrigin()
		flPad = flPad + hTarget:GetPaddedCollisionRadius()  --双半径叠加
	end

	--Missing: Setting target facing angle 设置目标朝向角度,指向出发点
	local vVelocity = self.vStartPosition - vHookPos
	vVelocity.z = 0.0

	local flDistance = vVelocity:Length2D() - flPad  --两者距离-碰撞半径
	vVelocity = vVelocity:Normalized() * self.hook_speed

	local info = {
		Ability = self,
		vSpawnOrigin = vHookPos,  --发射点
		vVelocity = vVelocity,    --速度
		fDistance = flDistance,	  --距离
		Source = self:GetCaster(), --发射者
	}

	ProjectileManager:CreateLinearProjectile( info )   --投射技能
	self.vProjectileLocation = vHookPos          --发射点

	if hTarget ~= nil and ( not hTarget:IsInvisible() ) and bTargetPulled then
		ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin() + self.vHookOffset, true )
		ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 0, 0, 0 ) )
		ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 1, 0, 0 ) )
		ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 6, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true)
	else
		ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true)
	end
	
	EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )
	EmitSoundOn( "Hero_Pudge.AttackHookRetract", hTarget )
	

	--动作添加移除
	if self:GetCaster():IsAlive() then
		self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
		self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 )
	end

	self.bRetracting = true

	if self.hVictim ~= nil then
		
		local hv = self.hVictim
		local vFinalHookPos = vLocation 
		local vVictimPosCheck = hv:GetOrigin() - vFinalHookPos
		local flPad = self:GetCaster():GetPaddedCollisionRadius() + hv:GetPaddedCollisionRadius()
		if vVictimPosCheck:Length2D() > flPad then
			local backDirectionTemp =  self.vStartPosition - hv:GetAbsOrigin()
			local backDirection =  backDirectionTemp:Normalized()
			local max_distance = backDirectionTemp:Length2D() - flPad * 4
			local traveled_distance = 0
			
			--目标或尽头坐标
			local hookPos = vFinalHookPos

			FindClearSpaceForUnit( hv, hookPos, false )		
			--钩到的目标移动
			GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
				function ()
					if traveled_distance < max_distance then
						local stepSpeed = self.hook_speed * 0.02 * 1.5	--动画与模型移动速度比
						local newPosition = hv:GetAbsOrigin() + backDirection * stepSpeed
						local tempLastDis = max_distance - traveled_distance
						if tempLastDis > flPad then
							hv:SetAbsOrigin(newPosition)
						else
							FindClearSpaceForUnit( hv, newPosition, false )
						end
						traveled_distance = traveled_distance + stepSpeed
					else
						hv:InterruptMotionControllers( true )
						hv:RemoveModifierByName( "modifier_meat_hook_lua" )
						self.hVictim = nil
						ParticleManager:DestroyParticle( self.nChainParticleFXIndex, true )
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

function pudge_meat_hook_lua:OnProjectileThink( vLocation )
	self.vProjectileLocation = vLocation
end

--------------------------------------------------------------------------------

function pudge_meat_hook_lua:OnOwnerDied()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
	self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
end

--------------------------------------------------------------------------------