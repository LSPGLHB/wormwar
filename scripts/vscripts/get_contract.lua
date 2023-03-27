require('myMaths')

function getRandomContract(keys)
    local contractList = GameRules.contractList

    local randomNumList= getRandomNumList(1,#contractList,2)

    local randomContractList = getRandomArrayList(contractList, randomNumList)

    local caster = keys.caster
	local playerID = caster:GetPlayerID()

    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "on_lua_to_js", {
        randomContractList = randomContractList
    } )
end