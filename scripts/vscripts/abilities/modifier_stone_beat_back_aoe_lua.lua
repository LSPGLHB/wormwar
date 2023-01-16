modifier_stone_beat_back_aoe_lua = class({})

--------------------------------------------------------------------------------
--[[
function modifier_stone_aoe:IsHidden()
	return true
end
]]

function modifier_stone_beat_back_aoe_lua:IsDebuff()
	return true
end

function modifier_stone_beat_back_aoe_lua:EffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_stone_beat_back_aoe_lua:EffectAttachType()
	return "follow_overhead"
end
--------------------------------------------------------------------------------

function modifier_stone_beat_back_aoe_lua:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
