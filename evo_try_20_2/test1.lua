ip = require "n200_ip6"
nw = require'Nw'

--path = '//storage//emulated//0//qlua5//projs21//evo_try_20'
path = '\\neveix_Feb2021\\evo_try_20'

require(path.."/world")
require(path.."/seeds")
require(path.."/trees")
require(path.."/genome")

do
    local a = nw.read('random.txt')
    print ("seed:"..a)
    math.randomseed (a)
end

debug = true

stage = 1
com = ''
genom = genome.create()
treecanbe = true

-- максимальный возраст деревьев
maxage = 16

function beforeinput()
    if game.previousIS[1] == "" or com=='q' or com=='e' then
        if trees[1] then
          io.write(tostring(trees[1].energy))
          if treecanbe then
            print(' (can be)')
          else
            print(' (cant be)')
          end
        end
        world.drawworld()
    else
        
    end
end



function gameloop()
    --print ("before input called")
    
    world.resetlight2()
    
    -- семена стираются
    
    for i = 1,#seed do
        set (seed[i].x,seed[i].y," ")
    end
    
    -- если ниже семечек земля, они превращаются в отростки
    
    local oldseeds = {}
    
    for i = 1,#seed do
        local s = seed[i]
        if get (s.x,s.y+1).sym=="#" then
            --trees.create(s.x,s.y,s.genom,s.energy)
            --seed.destroy(s)
        else
            oldseeds[#oldseeds+1]=s
        end
        seed[i] = nil
    end
    
    -- просчитывается энергия дерева
    
    for i = 1,#trees do
        local t = trees[i]
        
        t:recieveenergy()
        t:lostenergy()
    end
    
    -- деревья умирают от недостатка эн.
    
    local newtrees = {}
    
    for i = 1,#trees do
        local t = trees[i]
        if t.energy >0 then
            newtrees[#newtrees+1]=t
        else
            if debug then
              print('дерево умирает от недостатка энергии')
            end
            --t:destroy()
            treecanbe = false
            newtrees[#newtrees+1]=t
        end
        trees[i]=nil
    end
    
    for i = 1,#newtrees do
        trees[i]=newtrees[i]
    end
    newtrees =nil
    -- деревья ум. от старости
    
    local newtrees = {}
    
    for i = 1,#trees do
        local t = trees[i]
        if t.age < maxage then
            newtrees[#newtrees+1]=t
        else
            if debug then
              print('дерево умирает от старости')
            end
            t:die()
        end
        --t.age = t.age + 1
        trees[i]=nil
    end
    
    for i = 1,#newtrees do
        trees[i]=newtrees[i]
    end
    
    -- отростки растут и прев. в древ.
    
    for i = 1,#trees do
        local t = trees[i]
        t:grow()
    end
    
    -- семечка проверяет блок в ней, если он не воздух
    
    local newseeds={}
    
    for i = 1,#seed do
        local s = seed[i]
        if get(s.x,s.y).sym==" " then
            newseeds[#newseeds+1]=s
        end
        seed[i]=nil
    end
    
    -- если снизу воздух, семена двигаются вниз
    
    for i = 1,#oldseeds do
        local s = oldseeds[i]
        if get(s.x,s.y).sym==" " and get(s.x,s.y+1).sym==" " then
            s.y = s.y + 1
            seed[#seed+1]=oldseeds[i]
        end
    end
    oldseeds = nil
    
    -- добавляем новые семена к старым
    
    for i = 1,#newseeds do
        seed[#seed+1]=newseeds[i]
    end
    newseeds = nil
    
    -- семена рэндерятся
    
    for i = 1,#seed do
        local s = seed[i]
        set(s.x,s.y,"*")
    end
    
end

function dolastaction()
    if com == "q" then
      stage_prev()
    elseif com == "e" then
      stage_next()
    end
end

function stage_prev()
  com = 'q'
  if trees[1] then
    local stage1 = stage - 1
    print('предыдущая стадия ('..stage..')')
    local sym = treesym
    trees[1]:destroy()
    trees[1] = nil
    createtree()
    stage = stage1
    treesym = sym
    for i = 1,stage do
      gameloop()
    end
  else
    gameloop()
  end
end

function stage_next()
  com = 'e'
  if trees[1] then
    stage = stage + 1
    print('следующая стадия ('..stage..')')
  end
  gameloop()
end

function destroytree()
  if trees[1] then
    trees[1]:destroy()
    trees[1] = nil
  end
end

treesym = 'G'

function createtree()
  trees.create(math.ceil(world.w/2),world.h-1,genom,520,treesym)
  stage = 1
  treesym = randomsym()
  treecanbe = true
end

logenergy = 13

function setlogenergy(s)
  local n = s[2]
  n = tonumber(n)
  logenergy = n
end

function killtree()
  if trees[1] then
    trees[1]:die()
    trees[1] = nil
  end
end

function newgenom()
  genom = genome.create()
  print('created new genome')
end

function printgenom()
  genom:draw()
end

function newtree()
  destroytree()
  newgenom()
  createtree()
end

function game_start()
    if debug then
      print('building world...')
    end
    world.create(40,24)
    world.decorate()
    world.resetlight2()
    createtree()
    --world.createseeds{_,43}
    --world.drawworld()
    
    ip:interprete(game)
    
end



cmds_main = ip:newcmds()
cmds_main.s=ip.newcmd(game_start,"","Starts the game")

main = ip:newTextInterpreter("ET20 test",cmds_main,7)

cmds_game = ip:newcmds()
cmds_game[ "" ] = ip.newcmd(dolastaction,"","do last action")
cmds_game.q = ip.newcmd(stage_prev,"","prev stage")
cmds_game.e = ip.newcmd(stage_next,"","next stage")
cmds_game.des = ip.newcmd(destroytree,"","destroy tree")
cmds_game.crt = ip.newcmd(createtree,"","create tree")
cmds_game.setlogenergy = ip.newcmd(setlogenergy,"n","set 1 log energy (def 13)")
cmds_game.kill = ip.newcmd(killtree,"","kill tree")
cmds_game.newgen = ip.newcmd(newgenom,"","create new genome")
cmds_game.printgen = ip.newcmd(printgenom,"","prints genome")
cmds_game.ff = ip.newcmd(newtree,"","destroy tree, create new genom and new tree.")
cmds_game.drawl1 = ip.newcmd(world.drawlight1,"","draw world light 1")
cmds_game.drawl2 = ip.newcmd(world.drawlight2,"","draw world light 2")


--cmds_game.getsc = ip.newcmd(getseedcount,"","get seed count")
--cmds_game.gettc = ip.newcmd(gettreecount,"","get tree count")
--cmds_game.crs = ip.newcmd(world.createseeds,"n","create n seeds in random poses of map")

game = ip:newTextInterpreter("ET20 Testing session",cmds_game,7)

game.fBeforeInput = beforeinput

ip:interprete(main)

nw.write('random.txt',math.random(0,999999))