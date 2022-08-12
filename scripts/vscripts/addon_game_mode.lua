-- Generated from template

require('player_init')
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


	local time = GameRules:GetGameTime()
	PrecacheEveryThingFromKV( context )
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheUnitByNameSync("npc_dota_hero_tinker", context)
	time = time - GameRules:GetGameTime()
	print("DONE PRECACHEING IN:"..tostring(time).."Seconds")

	PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
	PrecacheResource("particle_folder", "particles/test_particle", context)
	-- Models can also be precached by folder or individually
	-- PrecacheModel should generally used over PrecacheResource for individual models
	PrecacheResource("model_folder", "particles/heroes/antimage", context)
	PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
	PrecacheModel("models/heroes/viper/viper.vmdl", context)
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


end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = wormWar()
	GameRules.AddonTemplate:InitGameMode()
end

function wormWar:InitGameMode()
	print( "Template addon is loaded." )
	self._GameMode = GameRules:GetGameModeEntity()
	self.CurrentScenario = nil
	self.flNextTimerConsoleNotify = -1

	--GameRules:SetCustomGameSetupTimeout(0) --设置设置(赛前)阶段的超时。 0 = 立即开始, -1 = 永远 (直到FinishCustomGameSetup 被调用) 
	--GameRules:SetCustomGameSetupAutoLaunchDelay( 0)--设置自动开始前的等待时间。 
	--GameRules:SetPreGameTime(0) --选择英雄与开始时间
	--GameRules:SetHeroSelectPenaltyTime( 0.0 )

	--设置4*4队伍组合
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 4 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 4 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 4 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 4 )


	--GameRules:SetPostGameTime( 0.0 )
	--GameRules:SetGoldPerTick( 0 )
	--GameRules:SetCustomGameAccountRecordSaveFunction( Dynamic_Wrap( wormWar, "OnSaveAccountRecord" ), self )

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )

	--监听单位被击杀
	ListenToGameEvent("entity_killed", Dynamic_Wrap(wormWar, "OnEntityKilled"), self)

	--监听单位重生
	--ListenToGameEvent("npc_spawned", Dynamic_Wrap(wormWar, "OnNPCSpawned"), self)

	--监听游戏进度
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(wormWar,"OnGameRulesStateChange"), self)
	



	--初始化玩家数据
	if temp_flag == 0 then
		initPlayerStats()
		temp_flag = 1
	end
end

-- Evaluate the state of the game
function wormWar:OnThink()
	
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function wormWar:OnEntityKilled (keys)
	
	--DeepPrintTable(keys)
	local unit = EntIndexToHScript(keys.entindex_killed)			 
    local name = unit:GetContext("name")
	local lable = unit:GetUnitLabel()

	--判断小怪被消灭，并刷新小怪
	if name then
		if name == "yang" then

			createUnit("yang")
		end
		if name == "niu" then
			createUnit("niu")
		end
	end
	
	if lable then
		local position=unit:GetAbsOrigin()
		local shoot = CreateUnitByName("yang", position, true, nil, nil, DOTA_TEAM_NEUTRALS)
	end
	
end

function wormWar:OnGameRulesStateChange( keys )
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_PRE_GAME then
			  --调用UI
			  CustomUI:DynamicHud_Create(-1,"UIButton","file://{resources}/layout/custom_game/UI_button.xml",nil)
	end
end