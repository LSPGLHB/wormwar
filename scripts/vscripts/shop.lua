require('myMaths')
--打开商店界面
function OnMyUIShopOpen( PlayerID )
	--CustomUI:DynamicHud_Destroy(PlayerID,"UIShopBox")
	CustomUI:DynamicHud_Create(PlayerID,"UIShopBox","file://{resources}/layout/custom_game/UI_shop.xml",nil)
end

function OnMyUIShopClose(PlayerID)
	CustomUI:DynamicHud_Destroy(PlayerID,"UIShopBox")
end

function initItemList()
	local itemList = GameRules.itemList
	--print("itemListitemList",itemList)
	local itemNameList = {}
	local itemShowNameList = {}
	local itemCostList = {}
	local itenIconList = {}
	local itemDescribeList = {}
	for name, item in pairs(itemList) do
		local itemName 
		local itemShowName
		local itemCost
		local itenIcon
		local itemDescribe
		local c = 0
		for key, value in pairs(item) do
			if key == "ItemType" and value == "equip" then
				itemName = name
				--print("itemName",itemName)
				c = c+1
			end
			if key == "ItemShowName" then
				itemShowName = value
				c = c+1
			end
			if key == "ItemCost" then
				itemCost = value
				c = c+1
			end
			if key == "IconSrc" then
				itenIcon = value
				c = c+1
			end
			if key == "ItemDescribe" then
				itemDescribe = value
				c = c+1
			end
			if c == 5 then
				table.insert(itemNameList,itemName)
				table.insert(itemShowNameList,itemShowName)
				table.insert(itemCostList,itemCost)
				table.insert(itenIconList,itenIcon)
				table.insert(itemDescribeList,itemDescribe)
				break
			end
		end
	end
	GameRules.itemNameList = itemNameList
	GameRules.itemShowNameList = itemShowNameList
	GameRules.itemCostList = itemCostList
	GameRules.itenIconList = itenIconList
	GameRules.itemDescribeList = itemDescribeList



	
end

function getPlayerShopListByRandomList(playerID, randomNumList)
	local itemNameList = GameRules.itemNameList
	local itemShowNameList = GameRules.itemShowNameList
	local itemCostList = GameRules.itemCostList
	local itenIconList = GameRules.itenIconList
	local itemDescribeList = GameRules.itemDescribeList

	local randomItemNameList = getRandomArrayList(itemNameList, randomNumList)
	local randomItemShowNameList = getRandomArrayList(itemShowNameList, randomNumList)
	local randomItemCostList = getRandomArrayList(itemCostList, randomNumList)
	local randomItemIconList = getRandomArrayList(itenIconList, randomNumList)
	local randomItemDescribeList = getRandomArrayList(itemDescribeList, randomNumList)

	local listLength = #randomItemNameList
	--print("listLength",listLength)
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getShopItemListLUATOJS", {
		num = listLength, 
		randomItemNameList = randomItemNameList, 
		randomItemShowNameList = randomItemShowNameList, 
		randomItemCostList = randomItemCostList,
		randomItemIconList = randomItemIconList,
		randomItemDescribeList = randomItemDescribeList
	})
end






