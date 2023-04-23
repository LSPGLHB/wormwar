--发送到前段显示信息
function OnGetTimeCount(round,step,stepTime,gameTime,playerID)
    print("======OnGetTimeCount======",playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIBannerMsgBox")
	CustomUI:DynamicHud_Create(playerID,"UIBannerMsgBox","file://{resources}/layout/custom_game/UI_banner_msg.xml",nil)
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getTimeCountLUATOJS", {
        round=GameRules.NumberStr[round],
        step=step,
        stepTime=stepTime,
        gameTime=gameTime
    } )
end



function getNowTime()
    local time = GameRules:GetGameTime() - GameRules.PreTime
    time = math.floor(time)
    local min =  math.floor(time / 60)
    local sec =  time % 60
    if min < 10 then
        min = "0"..min
    end
    if sec < 10 then
        sec = "0"..sec
    end
    local timeStr = min .. ":" .. sec
    return timeStr
end



--游戏开始
function gameProgress()
    --游戏轮数
    local gameRound = 1
    
    GameRules.winTeam = DOTA_TEAM_GOODGUYS
    GameRules.NumberStr ={"一","二","三","四","五","六","七","八","九","十","十一","十二","十三"} 


    onStepLoop(gameRound)
end

function onStepLoop(gameRound)

    --准备阶段时长
    local preTime = 10
    local battleTime = 15
    local gameRoundMax = 10

    print("gameRound:"..gameRound)
    
    
   
    --运行预备阶段倒计时
    prepareStep(gameRound,preTime)

    --预备阶段结束后启动战斗阶段
    Timers:CreateTimer(preTime + 1,function ()
        print("onStepLoop1========over")
        
        --运行战斗阶段倒计时
        battleStep(gameRound,battleTime,gameRoundMax)

        return nil
    end)
   
end
--预备阶段
function prepareStep(gameRound,preTime)
    print("onStepLoop1========start")

    local step1 = "预备阶段倒数："
    local interval = 1.0

    --每次轮回初始化地图与数据
    gameRoundInit()
    
    --信息发送到前端
    Timers:CreateTimer(interval,function ()
        local gameTime = getNowTime()
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
                OnGetTimeCount(gameRound,step1,preTime,gameTime,playerID)
            end
        end
        preTime = preTime - 1

        if preTime < 0  then
            return nil
        end
        return interval

    end)
   
end

--战斗阶段
function battleStep(gameRound,battleTime,gameRoundMax)
    --print("onStepLoop2========start")
    local step2 = "战斗时间还有："

    --扫描进程
    local interval = 1.0

    Timers:CreateTimer(interval,function ()
        --print("onStepLoop2========check")
        local gameTime = getNowTime()
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
                OnGetTimeCount(gameRound,step2,battleTime,gameTime,playerID)	
            end
        end

        battleTime = battleTime - 1
        --此处还需要加入两队人数判断，死光就结束

        if battleTime < 0 then
            --print("onStepLoop2========over")
            gameRound = gameRound + 1
            if gameRound < gameRoundMax then
                onStepLoop(gameRound)
            else
                --print("GAME========OVER")
               -- GameRules:SetGameWinner(GameRules.winTeam)
            end

            return nil
        end

        return interval
    end)
end

--每次轮回地图与玩家数据初始化
function gameRoundInit()
    print("gameRoundInit")
    --用于传送的位置标记实体
    local initPoint1 = Entities:FindByName(nil,"youxia") --找到实体
    local initPoint2 = Entities:FindByName(nil,"player2")--找到实体
    local initPoint3 = Entities:FindByName(nil,"player3") 
    local initPoint4 = Entities:FindByName(nil,"player4") 
    local initPoint5 = Entities:FindByName(nil,"player5") 
    local initPoints = {}
    table.insert(initPoints,initPoint1)
    table.insert(initPoints,initPoint2)
    table.insert(initPoints,initPoint3)
    table.insert(initPoints,initPoint4)
    table.insert(initPoints,initPoint5)


    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then

            local initPoint = initPoints[1] --数组从1开始
            local initPos = initPoint:GetAbsOrigin()
            local player = PlayerResource:GetPlayer(playerID)
            local hero = player:GetAssignedHero() --PlayerResource:GetSelectedHeroEntity(playerID)

            local heroTeam = PlayerResource:GetTeam(playerID)--hero:GetTeam()
       
            --print("heroTeam:".. heroTeam ) -- GOOD=2, BAD=3
           -- print("goodguys:" .. DOTA_GC_TEAM_GOOD_GUYS)-- =0
           -- print("badguys:" .. DOTA_GC_TEAM_BAD_GUYS)-- =1

           --传送到指定地点
            FindClearSpaceForUnit( hero, initPos, false )

            --镜头跟随英雄

            PlayerResource:SetCameraTarget(playerID,hero)           
            Timers:CreateTimer(0.1,function ()
                PlayerResource:SetCameraTarget(playerID,nil)
                return nil
            end)



            --初始化所有临时BUFF（未做）


           --[[不知道有什么用
            local heros = HeroList:GetAllHeroes() 获取所有英雄
            for index, hero in ipairs(heros) do

            end
            ]]

        end
    end
end                                         