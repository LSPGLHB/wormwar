pudge_meat_hook_lua_reb = class({})
LinkLuaModifier( "modifier_meat_hook_followthrough_lua", "heroes/hero_pudge/modifiers/modifier_meat_hook_followthrough_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_meat_hook_lua", "heroes/hero_pudge/modifiers/modifier_meat_hook_lua.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function meathookOnUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster.hook_damage = ability:GetLevelSpecialValueFor( "hook_damage" , ability:GetLevel() - 1)
	caster.hook_speed = ability:GetSpecialValueFor( "hook_speed" )
	caster.hook_width = ability:GetSpecialValueFor( "hook_width" )
	caster.hook_distance = ability:GetLevelSpecialValueFor( "hook_distance"  , ability:GetLevel() - 1)
	caster.hook_followthrough_constant = ability:GetSpecialValueFor( "hook_followthrough_constant" ) --计算常数
	caster.vision_radius = ability:GetSpecialValueFor( "vision_radius" )
	caster.vision_duration = ability:GetSpecialValueFor( "vision_duration" )
end

function meathookOnSpellStart(keys)

	local caster = keys.caster
	local ability = keys.ability

	caster.bChainAttached = false
	if caster.hVictim ~= nil then
		caster.hVictim:InterruptMotionControllers( true )
	end

	caster.vStartPosition = caster:GetOrigin() 

	local vDirectionTemp = ability:GetCursorPosition() - caster.vStartPosition
	vDirectionTemp.z = 0.0
	local nDirection = (vDirectionTemp):Normalized()
	local vDirection = ( vDirectionTemp:Normalized() ) * caster.hook_distance   --指定方向的距离
	
	caster.vProjectileLocation = caster.vStartPosition

	--发射方向的终点
	caster.vTargetPosition = caster.vStartPosition + vDirection

	--飞钩过程中不能移动
	local flFollowthroughDuration = ( caster.hook_distance / caster.hook_speed * caster.hook_followthrough_constant )
	caster:AddNewModifier( caster, ability, "modifier_meat_hook_followthrough_lua", { duration = flFollowthroughDuration } )

	--设置飞行高度
	caster.vHookOffset = Vector( 0, 0, 96 )
	--发射方向的终点+高度
	local vHookTarget = caster.vTargetPosition + caster.vHookOffset

	local vKillswitch = Vector( ( ( caster.hook_distance / caster.hook_speed ) * 2 ), 0, 0 )

	local shootStartPos = caster:GetOrigin() + nDirection * 200

	local hook = CreateUnitByName("shootUnit", shootStartPos, true, nil, nil, caster:GetTeam())

	--ParticleManager:CreateParticle("particles/invoker_kid_debut_wex_orb_test.vpcf", PATTACH_ABSORIGIN_FOLLOW, hook) 

	local traveled_distance = 0

	moveMeathook(hook, traveled_distance, caster.hook_distance, nDirection, caster.hook_speed, ability, keys)

	caster.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/pudge_meathook_test.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleAlwaysSimulate( caster.nChainParticleFXIndex )
	ParticleManager:SetParticleControlEnt( caster.nChainParticleFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster:GetOrigin() + caster.vHookOffset, true )
	ParticleManager:SetParticleControl( caster.nChainParticleFXIndex, 1, vHookTarget )   --指定发射方向的终点(起始坐标)红色飞镖头
	ParticleManager:SetParticleControl( caster.nChainParticleFXIndex, 2, Vector( caster.hook_speed, caster.hook_distance, caster.hook_width ) )  --出钩+链条
	ParticleManager:SetParticleControl( caster.nChainParticleFXIndex, 3, vKillswitch )    			--钩子带血
	ParticleManager:SetParticleControl( caster.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )    	--钩子旋转
	ParticleManager:SetParticleControl( caster.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )		--是否起钩
	ParticleManager:SetParticleControlEnt( caster.nChainParticleFXIndex, 6, caster, PATTACH_CUSTOMORIGIN, nil, caster:GetOrigin(), true )

	EmitSoundOn( "Hero_Pudge.AttackHookExtend", caster)

end

function moveMeathook(shoot, traveled_distance, max_distance, direction, speed, ability, keys)
	local speedmod = speed * 0.02 * 1.5  --钩到的东西速度比（收钩）
	local speedTimer = speed * 0.02 * 1.7 --子弹的移动速度比
	local caster = keys.caster
	--飞钩过程中的时间
	local flFollowthroughDuration = ( caster.hook_distance / caster.hook_speed * 1)
	
	shoot:SetForwardVector(Vector(direction.x, direction.y, 0)) --发射方向
	shoot:SetAbsOrigin(shoot:GetAbsOrigin() + Vector(0,0,50)) --发射高度
	
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
		--大循环判断发射后是否到尽头
		local shootHp = shoot:GetHealth()--判断子弹是否被消灭
		if traveled_distance < max_distance and shootHp > 0 then
			shoot:SetAbsOrigin(shoot:GetAbsOrigin() + direction * speedTimer)
			traveled_distance = traveled_distance + speedTimer
			local hitTarget = shootHit(shoot)

			-- 命中目标		
			if hitTarget ~= nil then
				--中弹声音
				StopSoundOn( "Hero_Pudge.AttackHookExtend", caster)
				EmitSoundOn( "Hero_Pudge.AttackHookImpact", shoot )
				EmitSoundOn( "Hero_Pudge.AttackHookExtend", caster)
				--中弹动画
				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, shoot )
				ParticleManager:SetParticleControlEnt( nFXIndex, 0, shoot, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
				hitTarget:AddNewModifier( caster, ability, "modifier_meat_hook_lua", nil )
				--收钩动画
				ParticleManager:SetParticleControlEnt( caster.nChainParticleFXIndex, 1, hitTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hitTarget:GetOrigin() + caster.vHookOffset, true )
				ParticleManager:SetParticleControl( caster.nChainParticleFXIndex, 4, Vector( 0, 0, 0 ) )
				ParticleManager:SetParticleControl( caster.nChainParticleFXIndex, 5, Vector( 1, 0, 0 ) )
				ParticleManager:SetParticleControlEnt( caster.nChainParticleFXIndex, 6, caster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster:GetOrigin() + caster.vHookOffset, true)
				--钩到目标拉回
				local shotPos = shoot:GetAbsOrigin() --子弹目标
				local vVictimPosCheck = hitTarget:GetOrigin() - shotPos  --子弹和目标的距离
				local flPad =  hitTarget:GetPaddedCollisionRadius() + caster:GetPaddedCollisionRadius() --子弹与目标的半径和
				
				if vVictimPosCheck:Length2D() > flPad then
					local hookPos = shotPos + direction * flPad
					local backDirectionTemp =  caster.vStartPosition - hitTarget:GetAbsOrigin()
					local back_distance = backDirectionTemp:Length2D() - flPad *2
					local traveled_distance = 0
					--把目标拉到钩子上
					FindClearSpaceForUnit( hitTarget, hookPos, false )	
					--钩到的目标移动
					GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
						function ()
							if traveled_distance < back_distance then
								local newPosition = hitTarget:GetAbsOrigin() - direction * speedmod 
								local tempLastDis = back_distance - traveled_distance
								if tempLastDis > flPad then
									hitTarget:SetAbsOrigin(newPosition)
								else
									FindClearSpaceForUnit( hitTarget, newPosition, false )
								end
								traveled_distance = traveled_distance + speedmod
							else
								hitTarget:InterruptMotionControllers( true )
								hitTarget:RemoveModifierByName( "modifier_meat_hook_lua" )
								ParticleManager:DestroyParticle( caster.nChainParticleFXIndex, true )
								StopSoundOn( "Hero_Pudge.AttackHookExtend", caster)
								StopSoundOn( "Hero_Pudge.AttackHookRetract", hitTarget )
								EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", caster)
								return nil
							end
							return 0.02
						end,0)
				end
				StopSoundOn( "Hero_Pudge.AttackHookExtend", caster)
				shoot:ForceKill(true)
				shoot:AddNoDraw()
				return nil
			end
		else
			--超出射程没有命中或被打爆，钩子返回
			if shoot then 		
				StopSoundOn( "Hero_Pudge.AttackHookExtend", caster)
				EmitSoundOn( "Hero_Pudge.AttackHookExtend", caster)				
			
				ParticleManager:SetParticleControlEnt( caster.nChainParticleFXIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster:GetOrigin() + caster.vHookOffset, true)

				shoot:ForceKill(true)
				shoot:AddNoDraw()	

				GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
				function () 
					StopSoundOn( "Hero_Pudge.AttackHookExtend", caster ) 
					ParticleManager:DestroyParticle( caster.nChainParticleFXIndex, true )
					
				end, flFollowthroughDuration)
				
				return nil
			end
		end
      return 0.02
     end,0)
end

--命中目标
function shootHit(shoot)
	local position=shoot:GetAbsOrigin()
	--寻找目标
	local aroundUnit=FindUnitsInRadius(DOTA_TEAM_NEUTRALS, 
										position, 
										nil, 
										100,
										DOTA_UNIT_TARGET_TEAM_FRIENDLY,
										DOTA_UNIT_TARGET_ALL,
										DOTA_UNIT_TARGET_FLAG_NONE,
										FIND_ANY_ORDER,
										false)
	
	for k,v in pairs(aroundUnit) do
		local lable=v:GetContext("name")
		local isHero= v:IsHero()
		--此处可判断类型
		--实现伤害
		--local damage = ability:GetAbilityDamage()
		--ApplyDamage({victim = v, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})		
		return v
	end	
	return nil

end
--------------------------------------------------------------------------------
