
-- evo_try_20 build11

ip = require "n200_ip7"
nw = require'Nw'
ran = require'n200_random'

PCmode = true

if PCmode then
  path = '/neveix_Feb2021/evo_try_20_2'
else
  path = '/storage/emulated/0/qlua5/projs21/evo_try_20_2'
end

require(path.."/world")
require(path.."/seeds")
require(path.."/trees")
require(path.."/genome")

exit = false
debug = 0

-- максимальный возраст деревьев
maxage = 16
logenergy = 6 --13

function beforeinput()
    local lasts = game.previousIS[1]
    if lasts == "" or lasts == 'sim' or lasts=='crs' then
      gameloop()
      act_draw()
        --world.drawworld()
    elseif lasts == "a" or lasts == "d" then
      act_draw()
    else
        --print ("действий не происходит ")
    end
    
end

function act_draw()
  world.drawscreen(150,scrx)--252,1)--world.w-1)
end


function gameloop()
    -- семена стираются
    
    for i = 1,#seed do
        set (seed[i].x,seed[i].y," ")
    end
    
    if debug > 1 then
      print('Семена стёрлись')
    end
    
    -- если ниже семечек земля, они превращаются в отростки
    
    local oldseeds = {}
    
    for i = 1,#seed do
        local s = seed[i]
        if get (s.x,s.y+1)=="#" then
            trees.create(s.x,s.y,s.genom,s.energy)
            --seed.destroy(s)
        else
            oldseeds[#oldseeds+1]=s
        end
        seed[i] = nil
    end

    if debug > 1 then
      print('Семена превратились в отростки')
    end

    world.resetlight()
    
    if debug > 1 then
      print('освещение мира ресетнулось')
    end
    -- просчитывается энергия дерева
    
    for i = 1,#trees do
        local t = trees[i]
        t:recieveenergy()
        t:lostenergy()
    end

    if debug > 1 then
      print('просчиталась энергия дерева')
    end

    -- деревья умирают от недостатка эн.
    
    local newtrees = {}
    
    for i = 1,#trees do
        local t = trees[i]
        if t.energy >0 then
            newtrees[#newtrees+1]=t
        else
            if debug>=1 then
              print('дерево умирает от недостатка энергии')
            end
            t:destroy()
        end
        trees[i]=nil
    end
    
    for i = 1,#newtrees do
        trees[i]=newtrees[i]
    end
    newtrees =nil
    
    if debug > 1 then
      print('деревья умирают от нед. энергии')
    end

    -- деревья ум. от старости
    
    local newtrees = {}
    
    for i = 1,#trees do
        local t = trees[i]
        if t.age < maxage then
            newtrees[#newtrees+1]=t
        else
            if debug>=1 then
              print('дерево умирает от старости')
            end
            t:die()
        end
        t.age = t.age + 1
        trees[i]=nil
    end
    
    for i = 1,#newtrees do
        trees[i]=newtrees[i]
    end

    if debug > 1 then
      print('деревья умирают от старости')
    end

    -- отростки растут и прев. в древ.
    
    for i = 1,#trees do
        local t = trees[i]
        t:grow()
    end
    
    if debug > 1 then
      print('деревья проросли')
    end
    
    -- семечка проверяет блок в ней, если он не воздух
    
    local newseeds={}
    
    for i = 1,#seed do
        local s = seed[i]
        if get(s.x,s.y)==" " then
            newseeds[#newseeds+1]=s
        end
        seed[i]=nil
    end
    
    if debug > 1 then
      print('обработаны новые семена')
    end
    
    -- если снизу воздух, семена двигаются вниз
    
    for i = 1,#oldseeds do
        local s = oldseeds[i]
        if get(s.x,s.y)==" " and get(s.x,s.y+1)==" " then
            s.y = s.y + 1
            seed[#seed+1]=oldseeds[i]
        end
    end
    oldseeds = nil

    if debug > 1 then
      print('обработаны старые семена')
    end

    -- добавляем новые семена к старым
    
    for i = 1,#newseeds do
        seed[#seed+1]=newseeds[i]
    end
    newseeds = nil
    
    if debug > 1 then
      print('семена совмещены')
    end
    
    -- семена рэндерятся
    
    for i = 1,#seed do
        local s = seed[i]
        set(s.x,s.y,"*")
    end
    
    if debug > 1 then
      print('семена зарэндерены')
    end
    
end

function dolastaction()
end

function setlogenergy(s)
  if s[2]=='' or s[2]==nil then
    print('Logenergy == '..logenergy)
  else
    local n = tonumber( s[2]) or 13
    logenergy = n
    print('Logenergy now = '..n)
  end
end

function settreelife(s)
  if s[2] then
    local n = tonumber(s[2]) or 16
    if n > 1 and n < 120 then
      print('MaxAge now = '..n)
      maxage = n
    else
      print('Error')
    end
  else
    print('MaxAge == '..maxage)
  end
end

function simulate_game(s)
  if s[2] then
    local n = tonumber(s[2]) or 1
    
    if n > 200 then
      print('Game will simulate '..n..' steps? (y/n)')
      if not (io.read()=='y') then
        return
      end
    end
    local lastr = 0
    local fr = 10
    if n < 1000 then
      fr = 15
    elseif n < 3000 then
      fr = 10
    elseif n < 10000 then
      fr = 5
    elseif n < 30000 then
      fr = 2
    else
      fr = 1
    end
    for e = 1,n-1 do
      local r = math.floor((e-1)/n*100)
      if r%fr==0 and lastr~=r then
        lastr = r
        if s[3] then
          act_draw()
        end
        print('Progress '..r..'%')
      end
      gameloop()
    end
  end
end

function screen_left(s) 
  local n = tonumber(s[2]) or scrspeed 
  n = math.abs(n)
  scrx = scrx - n; 
  if scrx < 1 then scrx = scrx+world.w end
  print('scrx = '..scrx)
end

function screen_right(s) 
  local n = tonumber(s[2]) or scrspeed; 
  n = math.abs(n)
  scrx = scrx + n; 
  if scrx > world.w then scrx = scrx - world.w end
end

function drawgenom(s)
  local n = tonumber(s[2]) or 1
  if trees[n] then
    print('Genome of ['..n..'] tree')
    trees[n].genom:draw()
  end
end

function gamestart_classic(s)
    local w = tonumber(s[2]) or 256
    if debug>=1 then
      print('Создан мир (КЛАССИКА) с шириной ',w)
    end
    maxage = 18
    world.create(w,24)
    world.decorate()
    world.createseeds{_,43}
    ip:interprete(game)
end

function gamestart_bigsize(s)
    local w = tonumber(s[2]) or 1024
    if debug>=1 then
      print('Создан мир (ОГРОМНЫЕ ДЕРЕВЬЯ) с шириной ',w)
    end
    maxage = 60
    world.create(w,45)
    world.decorate()
    world.createseeds{_,1024}
    ip:interprete(game)
end



cmds_main = ip:newcmds()
:cmd('s',gamestart_classic,"worldwidth","Starts game's classic mode")
:cmd('g',gamestart_bigsize,"worldwidth","Starts game's giant mode")

main = ip:newTextInterpreter("ET20",cmds_main,7)

cmds_game = ip:newcmds()
:cmd("",dolastaction,"","do last action")
:cmd('getsc',getseedcount,"","get seed count")
:cmd('gettc',gettreecount,"","get tree count")
:cmd('crs',world.createseeds,"n","create n seeds in random poses of map")
:cmd('logenergy',setlogenergy,"n","an integer of energy, what takes 1 log/plant of tree.")
:cmd('gette',gettreeenergy,"n","get tree[n] energy")
:cmd('sim',simulate_game,"n","simulates game for n steps")
:cmd('maxage',settreelife,"n","ticks , before tree die")
:cmd('a',screen_left,"n","move screen left n blocks")
:cmd('d',screen_right,"n","move screen right n blocks")
:cmd('drawgen',drawgenom,"n","draw genome of tree[n]")
cmds_game.le = cmds_game.logenergy
cmds_game.ma = cmds_game.maxage

game = ip:newIp("ET20_2 Ingame session",cmds_game,7)

game.fBeforeInput = beforeinput

ip:interprete(main)

ran.saverandom()