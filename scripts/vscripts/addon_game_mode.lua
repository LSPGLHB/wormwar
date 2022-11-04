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

	

	GameRules.DropTable = LoadKeyValues("scripts/kv/drops.kv") -- 导入掉落率的列表

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
	

	--监听物品被捡起
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(wormWar, "OnItemPickup"), self)


	--监听UI事件,这是新的事件管理器
	CustomGameEventManager:RegisterListener( "myui_open", OnMyUIOpen )
	CustomGameEventManager:RegisterListener( "js_to_lua", OnJsToLua )
	CustomGameEventManager:RegisterListener( "lua_to_js", OnLuaToJs )


	--初始化玩家数据
	if temp_flag == 0 then
		initPlayerStats()
		temp_flag = 1
	end

end

--死亡物品掉落
function RollDrops(unit)
	-- 读取上面读取的掉落KV文件，然后读取到对应的单位的定义文件
    local DropInfo = GameRules.DropTable[unit:GetUnitName()]
    if DropInfo then
-- 循环所有需要掉落的物品
        for item_name,chance in pairs(DropInfo) do
            if RollPercentage(chance) then
                -- 创建对应的物品
				--print("Creating "..item_name)
                local item = CreateItem(item_name, nil, nil)	--handle CreateItem(string item_name, handle owner, handle owner)
                local pos = unit:GetAbsOrigin()
				-- 用LaunchLoot函数可以有一个掉落动画，当然，也可以用CreateItemOnPositionSync来直接掉落。
              	-- item:LaunchLoot(false, 50, 50, pos)
				CreateItemOnPositionSync(pos,item)
				GameRules.BaoshiPos = pos
            end
        end
    end
end


--捡起物品监听
function wormWar:OnItemPickup (keys)
	--local unit = EntIndexToHScript(keys.dota_item_picked_up)
	local itemname = keys.itemname
	local PlayerID = keys.PlayerID
	local ItemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local HeroEntity = EntIndexToHScript(keys.HeroEntityIndex)
	--print("itemname",itemname)
	--print("PlayerID",PlayerID)
	
	local team = HeroEntity:GetTeam()
	local pos = GameRules.BaoshiPos  --全局变量保存好掉落的宝石位置

	if team == 2 and itemname == 'item_lvxie' then
		--print('pos:',pos) --宝石位置
		--print('drop:',itemname)

		HeroEntity:DropItemAtPositionImmediate(ItemEntity, pos)		
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

	RollDrops(unit)
	--判断小怪被消灭，并刷新小怪
	if name then
		if name == "yang" then

			createUnit("yang")



		end
		if name == "niu" then
			createUnit("niu")
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

--导入页面文件
function wormWar:OnGameRulesStateChange( keys )
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_PRE_GAME then
			  --调用UI
			CustomUI:DynamicHud_Create(-1,"UIButton","file://{resources}/layout/custom_game/UI_button.xml",nil)
			--CustomUI:DynamicHud_Create(-1,"UITopMsg","file://{resources}/layout/custom_game/UI_topMsg.xml",nil)
	end
end


--传参案例
function OnMyUIOpen( index,keys )
	--index 是事件的index值
	--keys 是一个table，固定包含一个触发的PlayerID，其余的是传递过来的数据
	CustomUI:DynamicHud_Create(keys.PlayerID,"UITopMsg","file://{resources}/layout/custom_game/UI_button.xml",nil)
end

function OnJsToLua( index,keys )
         print("pleyid:"..keys.pleyid.." magicname:"..tostring(keys.magicname))
        -- CustomUI:DynamicHud_Destroy(keys.PlayerID,"UIButton")
end

function OnLuaToJs( index,keys )
         CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(keys.PlayerID), "on_lua_to_js", {str="Lua"} )
       --  CustomUI:DynamicHud_Destroy(keys.PlayerID,"UIButton")
end