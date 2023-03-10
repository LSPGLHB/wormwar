require('myMaths')

--打开商店界面
function OnMyUIShopOpen( playerID )
	CustomUI:DynamicHud_Destroy(playerID,"UIShopBox")
	CustomUI:DynamicHud_Create(playerID,"UIShopBox","file://{resources}/layout/custom_game/UI_shop.xml",nil)
end


function getItemList()
	
	local itemList = GameRules.itemList
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
			if key == "itemType" and value == "equip" then
				itemName = name
				print("itemName",itemName)
				c = c+1
			end
			if key == "ItemShowName" then
				itemShowName = value
				c = c+1
			end
			if key == "itemCost" then
				itemCost = value
				c = c+1
			end
			if key == "itenIcon" then
				itenIcon = value
				c = c+1
			end
			if key == "itemDescribe" then
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

function getRandomItem(playerID)
	local itemNameList = GameRules.itemNameList
	local itemShowNameList = GameRules.itemShowNameList
	local itemCostList = GameRules.itemCostList
	local itenIconList = GameRules.itenIconList
	local itemDescribeList = GameRules.itemDescribeList

	local count = #itemNameList

	local randomNumList= getRandomNumList(1,count,2)

	local randomItemNameList = getRandomArrayList(itemNameList, randomNumList)
	local randomItemShowNameList = getRandomArrayList(itemShowNameList, randomNumList)
	local randomItemCostList = getRandomArrayList(itemCostList, randomNumList)
	local randomItemIconList = getRandomArrayList(itenIconList, randomNumList)
	local randomItemDescribeList = getRandomArrayList(itemDescribeList, randomNumList)

	OnMyUIShopOpen(playerID)

    
	local listLength = #randomItemNameList

	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getShopItemListLUATOJS", {
		num=listLength, 
		randomItemNameList = randomItemNameList, 
		randomItemShowNameList = randomItemShowNameList, 
		randomItemCostList = randomItemCostList,
		randomItemIconList = randomItemIconList,
		randomItemDescribeList = randomItemDescribeList
	})
end

