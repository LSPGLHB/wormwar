require('myMaths')
function openUIContractList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UIContractListPanelBox","file://{resources}/layout/custom_game/UI_contract_list.xml",nil)
end

function closeUIContractList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIContractListPanelBox")
end

function getRandomContractList(playerID)
    local count = GameRules.contractNameList 
    local randomContractNumList = getRandomNumList(1,#count,6)
    GameRules.randomContractNumList = randomContractNumList
    local contractNameList = getRandomArrayList(GameRules.contractNameList, randomContractNumList)
    local contractShowNameList = getRandomArrayList(GameRules.contractShowNameList, randomContractNumList)
    local contractIconList = getRandomArrayList(GameRules.contractIconList, randomContractNumList)
    local contractDescribeList = getRandomArrayList(GameRules.contractDescribeList, randomContractNumList)

    --OnUIContractListOpen( playerID )
    local listLength = #randomContractNumList
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getRandomContractListLUATOJS", {
        listLength = listLength,
        contractNameList = contractNameList,
        contractShowNameList = contractShowNameList,
        contractIconList = contractIconList,
        contractDescribeList = contractDescribeList
        
    })
end

--初始化天赋列表
function initContractList()
    print("==================initContractList================================")
    local contractList = GameRules.contractList
    local contractNameList = {}
    local contractShowNameList = {}
    local contractIconList = {}
    local contractDescribeList = {}

    for key, value in pairs(contractList) do

        local contractName = key
		local contractShowName = nil
		local contractIcon = nil
        local contractDescribe = nil
		local c = 0
        for k,v in pairs(value) do
            if k == "ShowName"  then
                contractShowName = v
                c = c+1
            end
            if k == "IconSrc" then
                contractIcon = v
                c = c+1
            end
            if k == "Describe" then
                contractDescribe = v
                c = c+1
            end
            if c == 3 then
                table.insert(contractNameList,contractName)
				table.insert(contractShowNameList,contractShowName)
				table.insert(contractIconList,contractIcon)
                table.insert(contractDescribeList,contractDescribe)
                break
            end
        end
    end
    GameRules.contractNameList = contractNameList
    GameRules.contractShowNameList = contractShowNameList
    GameRules.contractIconList = contractIconList
    GameRules.contractDescribeList = contractDescribeList
end



function openContractListKVTOLUA(keys)
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
   -- closeUIContractList(playerID)
    openUIContractList( playerID )
    getRandomContractList(playerID)
end

function closeContractListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUIContractList(playerID)
end

function refreshContractListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUIContractList(playerID)
    openUIContractList(playerID)
    getRandomContractList(playerID)
end



--获得天赋
function learnContractByNameJSTOLUA( index,keys )
    local playerID = keys.PlayerID
	local num  = keys.num
	local player = PlayerResource:GetPlayer(playerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    local randomContractNumList = GameRules.randomContractNumList

    local contractNameList = getRandomArrayList(GameRules.contractNameList, randomContractNumList)
    local contractShowNameList = getRandomArrayList(GameRules.contractShowNameList, randomContractNumList)
    local contractIconList = getRandomArrayList(GameRules.contractIconList, randomContractNumList)
    local contractDescribeList = getRandomArrayList(GameRules.contractDescribeList, randomContractNumList)

    local contractName = contractNameList[num]
    local contractShowName = contractShowNameList[num]
    local contractIcon = contractIconList[num]
    local contractDescribe = contractDescribeList[num]


    if player.contract ~= nil then
        local modifierName = "modifier_contract_"..player.contract.."_datadriven"
        hHero:RemoveModifierByName(modifierName)
        hHero:RemoveAbility(player.contract)
    end
    player.contract = contractName

    hHero:AddAbility(player.contract):SetLevel(1)



   
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "setContractUILUATOJS", {
        contractShowName = contractShowName,
        contractIcon = contractIcon,
        contractDescribe = contractDescribe
        
    } )

    closeUIContractList(playerID)
end


function contractOperation(playerID)
    local player = PlayerResource:GetPlayer(playerID)
    local contractName = player.contract

    local contractList = GameRules.contractList

    for key, value in pairs(contractList) do
        if (contractName == key) then
            for k,v in pairs(value) do
                if k == "vision_bonus"  then
                    player.contract_vision_bonus = v
                end
                if k == "health_bonus" then
                    player.contract_speed_bouns = v
                end
                if k == "speed_bouns" then
                    player.contract_hp_reduce_precent_final = v
                end
                
        
            end
            --break;
        end
    end


end




--[[
    local vision_bonus --增加英雄基础视野
    local health_bonus --增加基础生命
    local speed_bouns --增加基础移速
    local speed_sp_precent --增加移速百分比
    local speed_sp_duration --增加移速持续时间
    local mana_bonus --增加蓝量
    local mana_regen_bouns --增加蓝量恢复速度
    local C_speed_bonus --增加C技能射速
    local C_speed_bouns_precent --增加C技能射速百分比
    local C_range_bonus --增加C技能射程
    local C_range_bonus_precent --增加C技能射程百分比
    local C_damage_bonus --增加C技能的攻击力
    local C_damage_bonus_precent --增加C技能的攻击力百分比
    local C_control_bonus_precent --增加C技能控制时间百分比
    local C_energy_bonus_precent --增加C技能法魂量百分比
    local C_mana_expend_precent --增加C技能蓝量消耗
    local C_match_damage_bonus_precent --增加C技能相生时增加伤害百分比
    local C_match_control_bonus_precent --增加C技能相生时控制时间百分比
    local C_match_energy_bonus --增加C技能相生时法魂量
]]