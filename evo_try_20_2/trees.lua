trees = {}

trees.syms = 'abcdefghijklmnopqrstuvwxyz'

trees.syms = trees.syms:upper()

function randomsym()
  local d = math.random(1,26)
  return trees.syms:sub(d,d)
end

function trees.newplant(tree,x,y,gen)
    local a = {}
    a.x,a.y = x,y
    a.gen = gen
    a.tree = tree
    a.createdat = time
    set(x,y,tree.sym:lower())
    tree.plants[#tree.plants+1]=a
    return a
end

function trees.newlog(tree,x,y)
    local a = {}
    a.x,a.y = x,y
    a.tree = tree
    set(x,y,tree.sym)
    tree.logs[#tree.logs+1]=a
    return a
end

function trees.create(x,y,genom,energy,sym)
    local a = {}
    a.plants = {}
    a.logs = {}
    a.newplant = trees.newplant
    a.newlog = trees.newlog
    a.destroy = trees.destroy
    a.die = trees.die
    a.recieveenergy = trees.recieveenergy
    a.lostenergy = trees.lostenergy
    a.grow = trees.grow
    a.genom = genom
    a.energy = energy
    a.sym = sym or randomsym()
    a.age = 0
    if debug>=1 then
        print ("tree created, sym="..a.sym)
    end
    a:newplant(x,y,genom[1])
    trees[#trees+1]=a
    return a
end

function trees.destroy(a)
    -- очищаем древесину
    for i = 1, #a.logs do
        set(a.logs[i].x,a.logs[i].y," ")
    end
    -- очищаем отростки
    for i = 1, #a.plants do
        set(a.plants[i].x,a.plants[i].y," ")
    end
    
    if debug>=1 then
      print('tree destroyed')
    end
end

function trees.die(a)
    local ef1 = a.energy/#a.plants
    ef1 = math.floor(ef1)
    for i = 1,#a.plants do
        local p = a.plants[i]
        set(p.x,p.y,' ')
        local genom = a.genom
        if math.random(1,8)==1 then
          genom = genom:mutate()
        end
        seed.create(p.x,p.y,genom,ef1)
    end
    a:destroy()
end

function trees.recieveOneenergy(p)
  local e = light[world.xyton(p.x,p.y)] or error("Light is nil on "..p.x..', '..p.y)
  e = e * (world.h-p.y)
  return e
end

function trees.recieveenergy(a)
  local en = 0
  for i = 1,#a.plants do
    en = en + trees.recieveOneenergy(a.plants[i])
  end
  for i = 1,#a.logs do
    en = en + trees.recieveOneenergy(a.logs[i])
  end
  a.energy = a.energy + en
end

function trees.lostenergy(a)
    local en = 0
    local lost = logenergy
    for i = 1,#a.plants do
        en = en + lost
    end
    for i = 1,#a.logs do
        en = en + lost
    end
    a.energy = a.energy - en
end

function trees.grow(a)
    --старые отростки
    local oplants = a.plants
    a.plants = {}
    for i = 1,#oplants do
        local p = oplants[i]
        local triedtocreate = false
        for j = 1,4 do
            local x,y = 0,0
            if j == 1 then
                x=-1
            elseif j == 2 then
                y=-1
            elseif j == 3 then
                x=1
            elseif j == 4 then
                y=1
            end
            -- координаты будущего отростка
            x = x+p.x
            y = y+p.y
            if x==0 then
                x = world.w
            end
            if x==world.w+1 then
                x = 1
            end
            -- если ничего не мешает
            if p.gen[j]<=16 then
                triedtocreate = true
                if y>=1 and y<=world.h and world.trp(get(x,y)) then
                  --создаётся отросток
                  a:newplant(x,y,a.genom[ p.gen[j] ])
                end
            end
        end
        if triedtocreate then
          a:newlog(p.x,p.y)
        else
          a.plants[#a.plants+1] = p
        end
    end
end

function gettreecount()
  print('tree count = '..#trees)
end

function gettreeenergy(s)
  local i = tonumber(s[2]) or 1
  if trees[i] then
    print('Energy of tree['..i..'] ('..trees[i].sym..') = '..trees[i].energy..'. Energy for 1 seed = '..math.floor(trees[i].energy/#trees[i].plants))
  end
end
