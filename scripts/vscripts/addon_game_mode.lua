-- Generated from template

require('player_init')
require('game_progress')
require('get_magic')
require('get_contract')
require('contract_power')
require('shop')
require('button')
require('player_status')
require('util')
require('timers')
require('physics')
require('barebones')

if wormWar == nil then
	wormWar = class({})
end

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
		--预载precache.lua里的资源
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
	local init_flag = 0
	--GameRules:SetHeroSelectionTime(20)--选英雄时间(可用)
	GameRules:SetStrategyTime(0) --选英雄了后选装备时间（可用）
	
	--GameRules:SetShowcaseTime(20)
	--GameRules:SetTreeRegrowTime(60) -- 设置树木重生时间
	--GameRules:GetGameModeEntity():SetCustomBackpackSwapCooldown(0) --物品交换冷却
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(16) --英雄最高等级
	GameRules:SetCustomGameEndDelay(1)--设置游戏结束等待时间

	--GameRules:SetCustomGameSetupTimeout(1) --0后无法选英雄？？？设置设置(赛前)阶段的超时。 0 = 立即开始, -1 = 永远 (直到FinishCustomGameSetup 被调用) 
	--GameRules:SetCustomGameSetupAutoLaunchDelay(0)--设置自动开始前的等待时间。 
	GameRules.PreTime = 10
	GameRules:SetPreGameTime(GameRules.PreTime) --选择英雄与开始时间，吹号角时间
	GameRules.skillLabel = "skillLabel"
	GameRules.shopLabel ="shopLabel"
	--GameRules:SetHeroSelectPenaltyTime( 0.0 )



--[[用了启动会跳出
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

	GameRules.DropTable = LoadKeyValues("scripts/kv/drops.kv") -- 导入掉落率的列表
	GameRules.customAbilities = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")--导入技能表

	GameRules.itemList = LoadKeyValues("scripts/npc/npc_items_custom.txt")--导入装备表

	GameRules.contractList = LoadKeyValues("scripts/npc/contract/contract_all.kv")--导入契约表





	--设置4*4队伍组合
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 5 )


	--GameRules:SetPostGameTime( 0.0 )
	--GameRules:SetGoldPerTick( 0 )
	--GameRules:SetCustomGameAccountRecordSaveFunction( Dynamic_Wrap( wormWar, "OnSaveAccountRecord" ), self )

	--GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )

	--监听单位被击杀
	ListenToGameEvent("entity_killed", Dynamic_Wrap(wormWar, "OnEntityKilled"), self)

	--监听单位重生
	--ListenToGameEvent("npc_spawned", Dynamic_Wrap(wormWar, "OnNPCSpawned"), self)

	--监听游戏进度
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(wormWar,"OnGameRulesStateChange"), self)
	

	--监听物品被捡起
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(wormWar, "OnItemPickup"), self)



	--监听UI事件,这是按钮事件管理器 --(监听名，回调函数)
	CustomGameEventManager:RegisterListener( "js_to_lua", OnJsToLua ) 
	--商店按钮监听
	CustomGameEventManager:RegisterListener( "openShopJSTOLUA", openShopJSTOLUA )  
	CustomGameEventManager:RegisterListener( "closeShopJSTOLUA", closeShopJSTOLUA )  
	CustomGameEventManager:RegisterListener( "refreshShopJSTOLUA", refreshShopJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "buyShopJSTOLUA", buyShopJSTOLUA ) 

	--信息板按钮
	CustomGameEventManager:RegisterListener( "openPlayerStatusJSTOLUA", openPlayerStatusJSTOLUA )
	CustomGameEventManager:RegisterListener( "closePlayerStatusJSTOLUA", closePlayerStatusJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "refreshPlayerStatusJSTOLUA", refreshPlayerStatusJSTOLUA ) 

	--契约列表
	--CustomGameEventManager:RegisterListener( "openContractListJSTOLUA", openContractListJSTOLUA ) --打开启用KVTPLUA通道
	CustomGameEventManager:RegisterListener( "closeContractListJSTOLUA", closeContractListJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "refreshContractListJSTOLUA", refreshContractListJSTOLUA ) 
	CustomGameEventManager:RegisterListener( "learnContractByNameJSTOLUA", learnContractByNameJSTOLUA ) 
	
	--没用的家伙
	--CustomGameEventManager:RegisterListener( "lua_to_js", OnLuaToJs )
	--CustomGameEventManager:RegisterListener( "myui_open", OnMyUIOpen )
	--CustomGameEventManager:RegisterListener( "uimsg_open", OnUIMsg )


	--初始化玩家数据
	if init_flag == 0 then
		initMapStats() -- 初始化地图数据
		initItemList() -- 初始化物品信息
		initContractPower() --初始化契约容器
		initContractList() --初始化契约信息
		
		GetAbilityList()--初始化技能信息

		init_flag = 1
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

	--不能拾取会掉落
	if team == 2 and itemname == 'item_lvxie2' then
		--print('pos:',pos) --宝石位置
		--print('drop:',itemname)

		HeroEntity:DropItemAtPositionImmediate(ItemEntity, pos)		
	end	
end


-- Evaluate the state of the game
--GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )配合使用
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
	--判断小怪被消灭，并刷新小怪
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

--导入页面文件
function wormWar:OnGameRulesStateChange( keys )
	local state = GameRules:State_Get()
	--时间结束没有选的话，随机英雄
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
		--运行检查商店进程
		initShopStats()

		

		
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
					--PlayerResource:SetGold(playerID,50,true)	--所有玩家金钱增量
				
					--getRandomItem(playerID) 商店打开测试
					--print("============initbutton============")
					--CustomUI:DynamicHud_Destroy(-1,"UIButtonBox")
					--右下按钮显示
					CustomUI:DynamicHud_Create(playerID,"UIButtonBox","file://{resources}/layout/custom_game/UI_button.xml",nil)
					--契约板面
					CustomUI:DynamicHud_Create(playerID,"UIContractPanelBG","file://{resources}/layout/custom_game/UI_contract_box.xml",nil)
					
					--showPlayerStatusPanel( playerID ) 
					
			end
		end

		

		
--[[
		--开启游戏进程
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
		
		--gameProgress()
		
	end


end


