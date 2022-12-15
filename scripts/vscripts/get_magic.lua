--取出n个随机技能
function getRandomArrayList(arrayList, randomNumList)

    local randomArrayList = {}
    for i = 1, #randomNumList do
        local tempNum = randomNumList[i]
        table.insert(randomArrayList,arrayList[tempNum])
        --print("randomNumList"..tempNum..":"..abilityNameList[tempNum])
    end
   --[[
    print("randomAbilityList------------: "..#randomAbilityList)
    for i = 1, #randomAbilityList do
        print(i ..":".. randomAbilityList[i])
    end]]
    return randomArrayList
end

--获取count个F-T的不重复的随机数组      有问题，随机数不是理论数据
function getRandomNumList(from, to, count)
    local randomNum = 0
    local randomBox = {}
    local tempBox = {}
	--local count2 = count

    for  i = from , to do
       table.insert(tempBox,i)
    end
	--print("randomNum:============:",from,"-",to)
    while count > 0 do
        randomNum = math.random(1, to-from+1)
        table.insert(randomBox,tempBox[randomNum])
        table.remove(tempBox,randomNum)
        to = to - 1
        count = count -1

    end
    return randomBox
end


function getRandomMagic(keys)
    
	
    local abilityNameList = GameRules.abilityNameListC
	local iconSrcList = GameRules.iconSrcListC
	local nameList = GameRules.showNameListC
	local count = #abilityNameList
	--[[查看传回数据
	print("abilityNameList:count="..count)

	for i=1, #abilityNameList do

		print("abilityNameList=name="..abilityNameList[i])
	end
	]]
	local randomNumList= getRandomNumList(1,#abilityNameList,3)

    local randomAbilityList = getRandomArrayList(abilityNameList, randomNumList)
	local randomIconList = getRandomArrayList(iconSrcList, randomNumList)
	local randomNameList = getRandomArrayList(nameList, randomNumList)
	local caster = keys.caster
	local playerID = caster:GetPlayerID()
	
	OnMyUIOpen( playerID )
    --print("getRandomMagic========================playerID="..playerID)
    
	local listLength = #randomAbilityList

	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "on_lua_to_js", {num=listLength, abilityName=randomAbilityList, icon=randomIconList, showName= randomNameList} )
    
end

--传参案例
function OnMyUIOpen( playerID )
	CustomUI:DynamicHud_Destroy(playerID,"UIPanelBox")
	CustomUI:DynamicHud_Create(playerID,"UIPanelBox","file://{resources}/layout/custom_game/UI_button.xml",nil)
end

--点击学习技能
function OnJsToLua( index,keys )
		 --GetAbilityList()
		 local playerID = keys.PlayerID
		 CustomUI:DynamicHud_Destroy(playerID,"UIPanelBox")
		 --print("JSTOLUA")
         --print("playid:"..playerID.." magicname:"..tostring(keys.magicname))
		--获取英雄实体
		 local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
		 --local caster = keys.caster
		-- local localPlayer = Entities:GetLocalPlayer()
		-- local assignedHero = localPlayer:GetAssignedHero()
		-- local heroEntity = localPlayer:GetSelectedHeroEntity()

		--查看英雄所有技能
		local isNew = true
		for i=0,50 do
			local tempMagic = hHero:GetAbilityByIndex(i)
			--if tempMagic ~= nil then
			--	print("tempMagic",tempMagic:GetAbilityName())
			--end
			
			if tempMagic ~= nil and tempMagic:GetAbilityName() == "fire_storm_datadriven" then
				--print("is not new:".. tempMagic:GetAbilityName())
				isNew = false
				return
			end
		end
		--print("isNew:"..isNew)
		if isNew then
			--学习新技能
			hHero:AddAbility("fire_storm_datadriven")
			--caster:FindAbilityByName("fire_storm_datadriven"):SetHidden(true)     
			hHero:FindAbilityByName("fire_storm_datadriven"):SetLevel(1)
			local tempAbility = hHero:GetAbilityByIndex(3):GetAbilityName()
			--print("tempAbility:"..tempAbility)
			hHero:SwapAbilities( "fire_storm_datadriven", tempAbility, true , false )
			hHero:RemoveAbility(tempAbility) 
			-- CustomUI:DynamicHud_Destroy(keys.PlayerID,"UIButton")
		else
			print("is not new")
		end
		
end
--[[
function OnLuaToJs( index,keys )
         CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(keys.PlayerID), "on_lua_to_js", {str="Lua"} )
       --  CustomUI:DynamicHud_Destroy(keys.PlayerID,"UIButton")
end
]]
--把技能放到缓存区
function GetAbilityList()
	local abilityList = GameRules.customAbilities

	--重新组装数组
	local abilityListC = {}

	local abilityNameListC = {}
	local iconSrcListC = {}
	local showNameListC ={}
	--local flag = false
	for key, value in pairs(abilityList) do
		--print("GetAbilityKV-----: ", key, value)
		--table.insert(abilityNameList,key)	
		--flag = false
		local tempAbilityName = nil
		local tempiconSrc = nil
		local tempShowName = nil
		local c = 0
		for k,v in pairs(value) do
			if k == "AbilityLevel" and v == "C" then			

				tempAbilityName = key
				print("idName:"..key)
				c= c+1
			end
			if k == "iconSrc"  then
				tempiconSrc = v
				print("icon:"..v)
				c = c+1
			end
			if k == "AbilityShowName"  then
				tempShowName = v
				print("showName:"..v)
				c = c+1
			end	

			if c == 3 then
				table.insert(abilityNameListC,tempAbilityName)
				table.insert(iconSrcListC,tempiconSrc)
				table.insert(showNameListC,tempShowName)
				c=c+1
				break
			end
			
		end
	end
--[[
	for key,value in pairs(abilityList) do
		for k,v in pairs(abilityNameListC) do
			if key == v then
				local c = 0
				for name , val in pairs(value) do
					if name == "iconSrc"  then
						table.insert(iconSrcListC,val)
						print("icon:"..val)
						c = c+1
					end
					if name == "AbilityShowName"  then
						table.insert(showNameListC,val)
						print("name:"..val)
						c = c+1
					end	
					if c == 2 then
						--break
					end	
				end
			end
		end
	end
]]
	GameRules.abilityNameListC = abilityNameListC
	GameRules.iconSrcListC = iconSrcListC
	GameRules.showNameListC = showNameListC
end