function initPlayerStats()

    --真随机设定
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','') 
    math.randomseed(tonumber(timeTxt))

    PlayerStats={}
    for i = 0, 9 do
        PlayerStats[i] = {} --每个玩家数据包
        PlayerStats[i]['changdu'] = 0
    end

    --初始化刷怪
    local temp_zuoshang=Entities:FindByName(nil,"zuoshang") --找到左上的实体
    zuoshang_zuobiao=temp_zuoshang:GetAbsOrigin()

    local temp_youxia=Entities:FindByName(nil,"youxia") --找到左上的实体
    youxia_zuobiao=temp_youxia:GetAbsOrigin()

    --刷怪
    createUnit('yang')
    createUnit('yang')
    createUnit('yang')
    createUnit('yang')
    createUnit('yang')
    createUnit('yang')

    --createHuohai()
    --CreateHeroForPlayer("niu",-1)

end



function createUnit(unitName)
    local temp_x =math.random(youxia_zuobiao.x - zuoshang_zuobiao.x) + zuoshang_zuobiao.x
    local temp_y =math.random(youxia_zuobiao.y - zuoshang_zuobiao.y) + zuoshang_zuobiao.y
    local location = Vector(temp_x, temp_y ,0)

    local unit = CreateUnitByName(unitName, location, true, nil, nil, DOTA_TEAM_NEUTRALS)

    unit:SetContext("name", unitName, 0)
end

function createBaby(playerid)
    local followed_unit=PlayerStats[playerid]['group'][PlayerStats[playerid]['group_pointer']]
    local chaoxiang=followed_unit:GetForwardVector()
    local position=followed_unit:GetAbsOrigin()
    local newposition=position-chaoxiang*100
  
  
    local new_unit = CreateUnitByName("littlebug", newposition, true, nil, nil, followed_unit:GetTeam())
    new_unit:SetForwardVector(chaoxiang)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
       function ()
        new_unit:MoveToNPC(followed_unit)
        return 0.2
       end,0) 
    --new_unit:SetControllableByPlayer(playerid, true)
    PlayerStats[playerid]['group_pointer']=PlayerStats[playerid]['group_pointer']+1
    PlayerStats[playerid]['group'][PlayerStats[playerid]['group_pointer']]=new_unit

  end	

function createShoot(keys)
    for k,v in pairs(keys) do
        print("keys:",k,v)
    end
    local unit = keys.unit --EntIndexToHScript(keys.unit)
    local chaoxiang=unit:GetForwardVector()
    local position=unit:GetAbsOrigin()
    --local tempposition=position+chaoxiang*50
    local new_unit = CreateUnitByName("huoren", position, true, nil, nil, unit:GetTeam())
    new_unit:SetForwardVector(chaoxiang)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
      new_unit:MoveToPosition(position+chaoxiang*500)
      return 0.2
     end,0) 
end

function createHuohai()
  local temp_huohai = Entities:FindByName(nil,"huohai")
  local location = temp_huohai:GetAbsOrigin()
  local unit = CreateUnitByName("niu", location, true, nil, nil, DOTA_TEAM_NEUTRALS)
  GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
        unit:ForceKill(true) 
        unit:AddNoDraw() 
     end,10) 

  --[[
  local particle  = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_static_storm.vpcf", PATTACH_WORLDORIGIN, unit)
	ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(450, 450, 0))
	ParticleManager:SetParticleControl(particle, 2, Vector(450, 450, 0))
    ]]
end