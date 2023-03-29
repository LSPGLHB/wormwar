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
    local randomContractNumList = GameRules.randomContractNumList

    local contractNameList = getRandomArrayList(GameRules.contractNameList, randomContractNumList)
    local contractShowNameList = getRandomArrayList(GameRules.contractShowNameList, randomContractNumList)
    local contractIconList = getRandomArrayList(GameRules.contractIconList, randomContractNumList)
    local contractDescribeList = getRandomArrayList(GameRules.contractDescribeList, randomContractNumList)

    local contractName = contractNameList[num]
    local contractShowName = contractShowNameList[num]
    local contractIcon = contractIconList[num]
    local contractDescribe = contractDescribeList[num]

    player.contract = contractName

    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "setContractUILUATOJS", {
        contractShowName = contractShowName,
        contractIcon = contractIcon,
        contractDescribe = contractDescribe
        
    } )

    closeUIContractList(playerID)
end