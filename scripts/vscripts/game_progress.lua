require('player_power')
--发送到前段显示信息
function sendMsgOnScreenToAll(topTips,bottomTips)
    print("======sendMsgOnScreenToAll======")
    
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            CustomUI:DynamicHud_Destroy(playerID,"UIBannerMsgBox")
	        CustomUI:DynamicHud_Create(playerID,"UIBannerMsgBox","file://{resources}/layout/custom_game/UI_banner_msg.xml",nil)
            CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getTimeCountLUATOJS", {
                topTips = topTips,
                bottomTips = bottomTips
            } )
        end
    end
end






--游戏开始
function gameProgress()  
    gameInit()--游戏数据初始化，配置数据
    --游戏轮数
    local gameRound = 1
    prepareStep(gameRound)--开始游戏进程
end


--预备阶段
function prepareStep(gameRound)
    print("onStepLoop1========start"..gameRound)
    local step1 = "预备阶段倒数："
    local interval = 1 --运算间隔
    local loadingTime = 1.5 --延迟时间 
    local prepareTime = 10 --准备阶段时长
    --每次轮回初始化地图与数据
    gameRoundInit()

    --信息发送到前端
    Timers:CreateTimer(0 ,function ()
        --local gameTime = getNowTime()
        prepareTime = prepareTime - 1
    
        local topTips = "第"..NumberStr[gameRound].."轮战斗"
        local bottomTips = step1 .. prepareTime .. "秒"
        sendMsgOnScreenToAll(topTips,bottomTips)

        --时间结束则跳出计时循环进行下一阶段
        if prepareTime == 0  then
            --输出准备结束信息
            prepareOverMsgSend()
            --预备阶段结束后启动战斗阶段
            Timers:CreateTimer(loadingTime,function ()
                print("onStepLoop1========over")
                --进入战斗阶段倒计时
                battleStep(gameRound)
                return nil
            end)
            return nil
        end
        return interval
    end)

    
  
end

--战斗阶段
function battleStep(gameRound)
    --print("onStepLoop2========start")
    local step2 = "战斗时间还有："
    --扫描进程
    local interval = 1
    local loadingTime = 5
    local battleTime = 10 --战斗时间
    local gameRoundMax = 10 --时间宝石最大次数 

    --英雄位置初始化到战斗阶段
    playerPositionTransfer(battlePointsTeam1,playersTeam1)
    playerPositionTransfer(battlePointsTeam2,playersTeam2)

    Timers:CreateTimer(0,function ()
        --print("onStepLoop2========check")
        --local gameTime = getNowTime()
        battleTime = battleTime - 1

        local topTips = "第"..NumberStr[gameRound].."轮战斗"
        local bottomTips = step2 .. battleTime .. "秒"
        sendMsgOnScreenToAll(topTips,bottomTips)

        
        --此处还需要加入两队人数判断，死光就结束？？？？？？？？？？？


        if battleTime == 0 then -- 时间等于0结束
            --print("onStepLoop2========over")

            gameRound = gameRound + 1
            if gameRound < gameRoundMax then  --此处应判断双方胜利次数？？？？？？？？？？？？？
                --如果双方的时间宝石都未使用完，则跳出循环进行下一轮游戏？？？？？？？？？？？？？


                
                --输出回合结束信息
                roundOverMsgSend()
                --所有玩家不能控制
                allPlayerStop()
                --技能也需要停止运作？？？？？？？？？

                --进行下一轮战斗
                Timers:CreateTimer(loadingTime,function ()
                    prepareStep(gameRound) 
                    return nil
                end)
                return nil
            else
                --整局游戏结束
                --print("GAME========OVER")
               -- GameRules:SetGameWinner(winTeam)
            end
            return nil
        end
        return interval
    end)
end


--游戏数据初始化
function gameInit()
    print("======gameInit======")
    
    --用于传送的位置标记实体
    --预备地点
    preparePointsTeam1 = {}
    --战斗地点
    battlePointsTeam1 = {}

    local preparePointTeam1_1 = Entities:FindByName(nil,"youxia") --找到实体
    local preparePointTeam1_2 = Entities:FindByName(nil,"player2")--找到实体
    local preparePointTeam1_3 = Entities:FindByName(nil,"player3") 
    local preparePointTeam1_4 = Entities:FindByName(nil,"player4") 
    local preparePointTeam1_5 = Entities:FindByName(nil,"player5")   
    table.insert(preparePointsTeam1,preparePointTeam1_1)
    table.insert(preparePointsTeam1,preparePointTeam1_2)
    table.insert(preparePointsTeam1,preparePointTeam1_3)
    table.insert(preparePointsTeam1,preparePointTeam1_4)
    table.insert(preparePointsTeam1,preparePointTeam1_5)

    
    local battlePointTeam1_1 = Entities:FindByName(nil,"zuoshang") --找到实体
    local battlePointTeam1_2 = Entities:FindByName(nil,"player2")--找到实体
    local battlePointTeam1_3 = Entities:FindByName(nil,"player3") 
    local battlePointTeam1_4 = Entities:FindByName(nil,"player4") 
    local battlePointTeam1_5 = Entities:FindByName(nil,"player5")   
    table.insert(battlePointsTeam1,battlePointTeam1_1)
    table.insert(battlePointsTeam1,battlePointTeam1_2)
    table.insert(battlePointsTeam1,battlePointTeam1_3)
    table.insert(battlePointsTeam1,battlePointTeam1_4)
    table.insert(battlePointsTeam1,battlePointTeam1_5)

    
    preparePointsTeam2 = {}
    battlePointsTeam2 = {}
    --2队数据待录入
    
    playersTeam1 ={}
    playersTeam2 ={}
    playersAll = {}
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        --local initPoint = initPoints[1] --数组从1开始
        -- local initPos = initPoint:GetAbsOrigin()
        -- local player = PlayerResource:GetPlayer(playerID)
        -- local hero = player:GetAssignedHero() --PlayerResource:GetSelectedHeroEntity(playerID)
        --local heros = HeroList:GetAllHeroes() --获取所有英雄--暂时没用

        local heroTeam = PlayerResource:GetTeam(playerID)--hero:GetTeam() --print("heroTeam:".. heroTeam ) -- GOOD=2, BAD=3-- print("goodguys:" .. DOTA_GC_TEAM_GOOD_GUYS)-- =0 -- print("badguys:" .. DOTA_GC_TEAM_BAD_GUYS)-- =1

        if heroTeam == 2 then --GOOD天辉
            table.insert(playersTeam1,playerID)
        end

        if heroTeam == 3 then --BAD夜魇
            table.insert(playersTeam2,playerID)
        end
        table.insert(playersAll,playerID)
    end
--[[
    GameRules.preparePointsTeam1 = preparePointsTeam1
    GameRules.preparePointsTeam2 = preparePointsTeam2
    GameRules.battlePointsTeam1 = battlePointsTeam1
    GameRules.battlePointsTeam2 = battlePointsTeam2
    GameRules.playersTeam1 = playersTeam1
    GameRules.playersTeam2 = playersTeam2
    GameRules.playersAll = playersAll
    ]]
    winTeam = DOTA_TEAM_GOODGUYS
    GoodWin = 0
    BadWin = 0
    NumberStr ={"一","二","三","四","五","六","七","八","九","十","十一","十二","十三"} 

end


--每次轮回地图与玩家数据初始化
function gameRoundInit()
    print("gameRoundInit")
    --复活所有玩家

    --初始化所有临时BUFF（未做）
    initTempPlayerPower()

   
    --英雄位置初始化到预备阶段
    playerPositionTransfer(preparePointsTeam1,playersTeam1)
    playerPositionTransfer(preparePointsTeam2,playersTeam2)
     
end    




--指定玩家传送到指定地点
function playerPositionTransfer(points,playersID)
    print("playerPositionTransfer")
    for i = 1, #playersID do
        local point = points[i]
        local position = point:GetAbsOrigin()
        local playerID = playersID[i]
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)

        --传送到指定地点
        FindClearSpaceForUnit( hero, position, false )
        --过滤之前移动操作
        hero:MoveToPosition(position)
        --移除玩家不能控制
        allPlayerStopRemove()
        --镜头跟随英雄
        PlayerResource:SetCameraTarget(playerID,hero)           
        Timers:CreateTimer(0.1,function ()
            PlayerResource:SetCameraTarget(playerID,nil)
            return nil
        end)
    end
end

--定身
function allPlayerStop()
    local playersID = playersAll
    for i = 1, #playersID do
        local playerID = playersID[i]
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then 
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            hero:AddAbility("ability_init_stop"):SetLevel(1)
        end
    end
end
--移除定身
function allPlayerStopRemove()
    local playersID = playersAll
    for i = 1, #playersID do
        local playerID = playersID[i]
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            --解除不可控制状态
            if (hero:HasAbility("ability_init_stop")) then
                hero:RemoveAbility("ability_init_stop")
            end
            if(hero:HasModifier("modifier_init_stop")) then
                hero:RemoveModifierByName("modifier_init_stop")
            end
        end
    end
end


function prepareOverMsgSend()
    local topTips = "准备阶段结束"
    local bottomTips = "战斗即将开始" 
    sendMsgOnScreenToAll(topTips,bottomTips)
end

function roundOverMsgSend()
    local topTips = "此轮战斗结束"
    local bottomTips = "时间宝石启动，新的战斗将重新开始"
    sendMsgOnScreenToAll(topTips,bottomTips)
end


function getNowTime()
    local time = GameRules:GetGameTime() - GameRules.prepareTime
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