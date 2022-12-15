--发送到前段显示信息
function OnGetTimeCount(round,step,stepTime,gameTime,playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIMsgBox")
	CustomUI:DynamicHud_Create(playerID,"UIMsgBox","file://{resources}/layout/custom_game/UI_topMsg.xml",nil)
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "get_time_count", {round=round,step=step,stepTime=stepTime,gameTime=gameTime} )
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

function gameRoundInit()
    print("gameRoundInit")
    local initPoint1 = Entities:FindByName(nil,"player1") --找到实体
    local initPoint2 = Entities:FindByName(nil,"player2") --找到实体
    local initPoint3 = Entities:FindByName(nil,"player3") --找到实体
    local initPoint4 = Entities:FindByName(nil,"player4") --找到实体
    local initPoint5 = Entities:FindByName(nil,"player5") --找到实体
    local initPoints = {}
    table.insert(initPoints,initPoint1)
    table.insert(initPoints,initPoint2)
    table.insert(initPoints,initPoint3)
    table.insert(initPoints,initPoint4)
    table.insert(initPoints,initPoint5)

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then

           
           
            local initPoint = initPoints[1] --从1开始
            local initPos = initPoint:GetAbsOrigin()
            local player = PlayerResource:GetPlayer(playerID)
            local hero = player:GetAssignedHero()

            local heroTeam = PlayerResource:GetTeam(playerID)--hero:GetTeam()
       
            print("heroTeam:".. heroTeam ) -- GOOD=2, BAD=3
            print("goodguys:" .. DOTA_GC_TEAM_GOOD_GUYS)-- =0
            print("badguys:" .. DOTA_GC_TEAM_BAD_GUYS)-- =1

            FindClearSpaceForUnit( hero, initPos, false )

            --镜头跟随英雄
            PlayerResource:SetCameraTarget(playerID,hero)           
            Timers:CreateTimer(0.1,function ()
                PlayerResource:SetCameraTarget(playerID,nil)
                return nil
            end)

           --[[
            local heros = HeroList:GetAllHeroes() 获取所有英雄
            for index, hero in ipairs(heros) do

               

                
                
               
                
            end
            ]]

        end
    end
end

function gameProgress()
    --游戏轮数
    local gameRound = 1
    
    GameRules.winTeam = DOTA_TEAM_GOODGUYS

    onStepLoop(gameRound)
end

function onStepLoop(gameRound)

    --准备阶段时长
    local preTime = 5
    local battleTime = 10
    local gameRoundMax = 10

    print("gameRound:"..gameRound)
    --运行预备阶段倒计时
    prepareStep(gameRound,preTime)

    Timers:CreateTimer(preTime,function ()
        print("onStepLoop1========over")
        
        --运行战斗阶段倒计时
        battleStep(gameRound,battleTime,gameRoundMax)

        return nil
    end)
   
end
--预备阶段
function prepareStep(gameRound,preTime)
    print("onStepLoop1========start")

    local step1 = 1
    local interval = 1

    gameRoundInit()
    
    --信息发送到前端
    Timers:CreateTimer(0.1,function ()
        local gameTime = getNowTime()
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
                OnGetTimeCount(gameRound,step1,preTime,gameTime,playerID)
            end
        end
        preTime = preTime - 1

        if preTime == 0  then
            return nil
        end
        return interval

    end)
   
end

--战斗阶段
function battleStep(gameRound,battleTime,gameRoundMax)
    print("onStepLoop2========start")
    local step2 = 2

    --扫描进程
    local interval = 1.0

    Timers:CreateTimer(0.1,function ()
        print("onStepLoop2========check")
        local gameTime = getNowTime()
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
                OnGetTimeCount(gameRound,step2,battleTime,gameTime,playerID)	
            end
        end

        battleTime = battleTime - 1
 
        if battleTime == 0 then
            print("onStepLoop2========over")
            gameRound = gameRound + 1
            if gameRound < gameRoundMax then
                onStepLoop(gameRound)
            else
                print("GAME========OVER")
               -- GameRules:SetGameWinner(GameRules.winTeam)
            end

            return nil
        end

        return interval
    end)
end