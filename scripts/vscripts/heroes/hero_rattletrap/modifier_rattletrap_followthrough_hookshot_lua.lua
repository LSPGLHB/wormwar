modifier_rattletrap_hookshot_followthrough_lua = class({})

--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_followthrough_lua:IsHidden()
	return true
end


--------------------------------------------------------------------------------

function modifier_rattletrap_hookshot_followthrough_lua:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
