-- Generated from template

require('player_init')
require('game_progress')
require('get_magic')
require('util')
require('timers')
require('physics')
require('barebones')

if wormWar == nil then
	wormWar = class({})
end

temp_flag = 0

function PrecacheEveryThingFromKV( context )
	local kv_files = {
		"scripts/npc/npc_units_custom.txt","scripts/npc/npc_abilities_custom.txt","scripts/npc/npc_abilities_override.txt",
		"scripts/npc/npc_heroes_custom.txt","scripts/npc/npc_items_custom.txt"
	}
	for _, kv in pairs(kv_files) do
		local kvs = LoadKeyValues(kv)
		if kvs then
			print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
			PrecacheEverythingFromTable( context, kvs)
		end
	end
end

function PrecacheEverythingFromTable( context, kvtable)
	for key, value in pairs(kvtable) do
		if type(value) == "table" then
			PrecacheEverythingFromTable( context, value )
		else
			if string.find(value, "vpcf") then
				PrecacheResource( "particle",  value, context)
				print("PRECACHE PARTICLE RESOURCE", value)
			end
			if string.find(value, "vmdl") then 	
				PrecacheResource( "model",  value, context)
				print("PRECACHE MODEL RESOURCE", value)
			end
			if string.find(value, "vsndevts") then
				PrecacheResource( "soundfile",  value, context)
				print("PRECACHE SOUND RESOURCE", value)
			end
		end
	end

   
end

function Precache( context )

	print("BEGIN TO PRECACHE RESOURCE")
--[[

	local time = GameRules:GetGameTime()
	

	time = time - GameRules:GetGameTime()
	print("DONE PRECACHEING IN:"..tostring(time).."Seconds")
]]
	PrecacheEveryThingFromKV( context )
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheUnitByNameSync("npc_dota_hero_tinker", context)
	PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
	PrecacheResource("particle_folder", "particles/test_particle", context)
	-- Models can also be precached by folder or individually
	-- PrecacheModel should generally used over PrecacheResource for individual models
	PrecacheResource("model_folder", "particles/heroes/antimage", context)
	--PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
	--PrecacheModel("models/heroes/viper/viper.vmdl", context)
	-- Sounds can precached here like anything else
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
	-- Entire items can be precached by name
	-- Abilities can also be precached in this way despite the name
	PrecacheItemByNameSync("example_ability", context)
	PrecacheItemByNameSync("item_example_item", context)
	-- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
	-- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
	PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
	PrecacheUnitByNameSync("npc_dota_hero_enigma", context)

--[[
	print("Precache...")
    local precache_list = require("precache")
	for _, precache_item in pairs(precache_list) do
		--??????precache.lua????????????
		if string.find(precache_item, ".vpcf") then
			-- print('[precache]'..precache_item)
			PrecacheResource( "particle",  precache_item, context)
		end
		if string.find(precache_item, ".vmdl") then 	
			-- print('[precache]'..precache_item)
			PrecacheResource( "model",  precache_item, context)
		end
		if string.find(precache_item, ".vsndevts") then
			-- print('[precache]'..precache_item)
			PrecacheResource( "soundfile",  precache_item, context)
		end
		if string.find(precache_item, ".v") == false then
			-- print('[precache]'..precache_item)
			PrecacheResource( "particle_folder",  precache_item, context)
		end
    end
]]

end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = wormWar()
	GameRules.AddonTemplate:InitGameMode()
end

function wormWar:InitGameMode()
	print( "============Init Game Mode============" )

	--GameRules:SetHeroSelectionTime(20)--???????????????(??????)
	GameRules:SetStrategyTime(0) --??????????????????????????????????????????
	
	--GameRules:SetShowcaseTime(20)
	--GameRules:SetTreeRegrowTime(60) -- ????????????????????????
	--GameRules:GetGameModeEntity():SetCustomBackpackSwapCooldown(0) --??????????????????
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(16) --??????????????????
	GameRules:SetCustomGameEndDelay(1)--??????????????????????????????

	--GameRules:SetCustomGameSetupTimeout(1) --0???????????????????????????????????????(??????)?????????????????? 0 = ????????????, -1 = ?????? (??????FinishCustomGameSetup ?????????) 
	--GameRules:SetCustomGameSetupAutoLaunchDelay(0)--??????????????????????????????????????? 
	GameRules.PreTime = 10
	GameRules:SetPreGameTime(GameRules.PreTime) --?????????????????????????????????????????????

	--GameRules:SetHeroSelectPenaltyTime( 0.0 )



--[[?????????????????????
	GameRules:GetGameModeEntity():SetCustomBackpackSwapCooldown(0)
	GameRules:GetGameModeEntity():SetPauseEnabled(false)
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
    GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(false)
    GameRules:GetGameModeEntity():SetBuybackEnabled(false)
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():DisableHudFlip(true)
	GameRules:GetGameModeEntity():SetSendToStashEnabled(false)
]]

	self._GameMode = GameRules:GetGameModeEntity()
	self.CurrentScenario = nil
	self.flNextTimerConsoleNotify = -1

	GameRules.DropTable = LoadKeyValues("scripts/kv/drops.kv") -- ????????????????????????
	GameRules.customAbilities = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")--???????????????


	--??????4*4????????????
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 5 )


	--GameRules:SetPostGameTime( 0.0 )
	--GameRules:SetGoldPerTick( 0 )
	--GameRules:SetCustomGameAccountRecordSaveFunction( Dynamic_Wrap( wormWar, "OnSaveAccountRecord" ), self )

	--GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )

	--?????????????????????
	ListenToGameEvent("entity_killed", Dynamic_Wrap(wormWar, "OnEntityKilled"), self)

	--??????????????????
	--ListenToGameEvent("npc_spawned", Dynamic_Wrap(wormWar, "OnNPCSpawned"), self)

	--??????????????????
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(wormWar,"OnGameRulesStateChange"), self)
	

	--?????????????????????
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(wormWar, "OnItemPickup"), self)



	--??????UI??????,??????????????????????????? --(????????????????????????)
	CustomGameEventManager:RegisterListener( "js_to_lua", OnJsToLua )  
	
	--???????????????
	--CustomGameEventManager:RegisterListener( "lua_to_js", OnLuaToJs )
	--CustomGameEventManager:RegisterListener( "myui_open", OnMyUIOpen )
	--CustomGameEventManager:RegisterListener( "uimsg_open", OnUIMsg )


	--?????????????????????
	if temp_flag == 0 then
		initPlayerStats()
		GetAbilityList()
		temp_flag = 1
	end

end



--??????????????????
function RollDrops(unit)
	-- ???????????????????????????KV??????????????????????????????????????????????????????
    local DropInfo = GameRules.DropTable[unit:GetUnitName()]
    if DropInfo then
-- ?????????????????????????????????
        for item_name,chance in pairs(DropInfo) do
            if RollPercentage(chance) then
                -- ?????????????????????
				--print("Creating "..item_name)
                local item = CreateItem(item_name, nil, nil)	--handle CreateItem(string item_name, handle owner, handle owner)
                local pos = unit:GetAbsOrigin()
				-- ???LaunchLoot?????????????????????????????????????????????????????????CreateItemOnPositionSync??????????????????
              	-- item:LaunchLoot(false, 50, 50, pos)
				CreateItemOnPositionSync(pos,item)
				GameRules.BaoshiPos = pos
            end
        end
    end
end


--??????????????????
function wormWar:OnItemPickup (keys)
	--local unit = EntIndexToHScript(keys.dota_item_picked_up)
	local itemname = keys.itemname
	local PlayerID = keys.PlayerID
	local ItemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local HeroEntity = EntIndexToHScript(keys.HeroEntityIndex)
	--print("itemname",itemname)
	--print("PlayerID",PlayerID)
	
	local team = HeroEntity:GetTeam()
	local pos = GameRules.BaoshiPos  --??????????????????????????????????????????

	--?????????????????????
	if team == 2 and itemname == 'item_lvxie2' then
		--print('pos:',pos) --????????????
		--print('drop:',itemname)

		HeroEntity:DropItemAtPositionImmediate(ItemEntity, pos)		
	end	
end


-- Evaluate the state of the game
--GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )????????????
--[[
function wormWar:OnThink()
	
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end]]

function wormWar:OnEntityKilled (keys)
	
	--DeepPrintTable(keys)
	local unit = EntIndexToHScript(keys.entindex_killed)
    local name = unit:GetContext("name")
	local lable = unit:GetUnitLabel()

	
	RollDrops(unit)
	--???????????????????????????????????????
	if name then
		if name == "yang" then
			createUnit("niu",DOTA_TEAM_BADGUYS)
		end
		if name == "niu" then
			createUnit("niu",DOTA_TEAM_BADGUYS)
		end
	end
	
	--if lable == "mu" then
		--unit:ForceKill(true)
		--unit:AddNoDraw()
		--local position=unit:GetAbsOrigin()
		--local shoot = CreateUnitByName("niu", position, true, nil, nil, DOTA_TEAM_NEUTRALS)
	--end
	--if lable == "hookUnit" then
		--local position=unit:GetAbsOrigin()
		--local hookUnit = CreateUnitByName("hookUnit", position, true, nil, nil, DOTA_TEAM_NEUTRALS)
	--end
	
end

--??????????????????
function wormWar:OnGameRulesStateChange( keys )
	local state = GameRules:State_Get()
	--??????????????????????????????????????????
	if state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
                --if PlayerResource:GetPlayer(playerID) ~= nil and PlayerResource:IsValidPlayer(playerID) then
                if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
                        --print(PlayerResource:GetSelectedHeroID(playerID))
                        if PlayerResource:GetSelectedHeroID(playerID) == -1 then
                                PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection()
                        end
                end
        end
	end

	if state == DOTA_GAMERULES_STATE_PRE_GAME then		
		--print("DOTA_GAMERULES_STATE_PRE_GAME"..getNowTime())
		--????????????????????????
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
					PlayerResource:SetGold(playerID,0,true)			
			end
		end
--[[
		--??????????????????
		local countPreTime = GameRules.PreTime
		local sec = 1
		--local gameTime = getNowTime()
		Timers:CreateTimer(sec,function ()
			for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
					OnGetTimeCount(-1,nil,countPreTime,nil,playerID)

				end
			end	
			countPreTime = countPreTime - 1
			if countPreTime == 0 then
				gameProgress()
				return nil
			end		
			return sec
		end)
]]
	end

	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		--print("DOTA_GAMERULES_STATE_HERO_SELECTION"..getNowTime())
	end
	if state == DOTA_GAMERULES_STATE_INIT then
		--print("DOTA_GAMERULES_STATE_INIT"..getNowTime())
	end
	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

		--print("DOTA_GAMERULES_STATE_GAME_IN_PROGRESS"..getNowTime())
		
		gameProgress()
		
	end


end


