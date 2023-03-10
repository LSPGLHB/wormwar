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

--获取count个From-To的不重复的随机数组      
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
