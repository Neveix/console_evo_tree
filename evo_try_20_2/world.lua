world = {}
light = {}

function world.create(w,h)
    --[[for i = 1,w*h do
        --world[i].sym=" "
    end]]
    world.w = w
    world.h = h
    world.l = w*h
end

function world.decorate()
    for i = 1, world.w do
        set (i,world.h,"#")
    end
end

function world.set(x,y,sym)
    if x> world.w or y>world.h or sym==nil then
        print ("set error")
        return
    end
    world [world.xyton(x,y)] = sym
end
set=world.set

function world.get(x,y)
    if y<1 then y=1 end
    local res = world [world.xyton(x,y)] or " "
    return res
end
get=world.get

function world.ntoxy(n)
    local s = (n-1) % world.w +1
    return s, math.floor((n-s) / world.w) +1
end

function world.xyton(x,y)
  local n = x+(y-1)*world.w
  return n
end
xyton = world.xyton

ntoxy=world.ntoxy

function world.resetlight()
  light = {}
  if debug>=1 then
    print('ресетается освещение')
  end
  for i = 1, #trees do
    local t = trees[i]
    for j = 1,#t.plants do
      local p = t.plants[j]
      world.handleblocklight(p.x,p.y)
    end
    for j = 1,#t.logs do
      local p = t.logs[j]
      world.handleblocklight(p.x,p.y)
    end
  end
  if debug>=1 then
    print('ресет окончен')
  end
end

transparentblocks = {' ','*'}

function world.trp(b) --transparent
  local yes = false
  if b == nil or b == ' ' then return true end
  for i = 1,#transparentblocks do
    if b==transparentblocks[i] then
      yes = true
      break
    end
  end
  return yes
end
trp = world.trp

function world.handleblocklight(x,y)
  if light[xyton(x,y)] then
    return
  end
  local h = 1
  repeat
    if light[xyton(x,y-h)] then
      break
    end
    local b1 = get(x,y-h)
    -- проверка блоков воздуха выше
    -- нужно для оптимизации:
    if trp(b1) then
      local b2 = get(x,y-h-1)
      if trp(b2) then
        local b3 = get(x,y-h-2)
        if trp(b3) then
          light[xyton(x,y-h)] = 3
          break
        end
      end
    end
    if y-h<=1 then
      light[xyton(x,y-h)] = 3
      break
    end
    h = h + 1

  until false
  for i = y-h+1 , y do
    local up = light [xyton(x,i-1)]
    if trp(get(x,i-1)) then
      if up < 3 then
        light [xyton(x,i)] = up+1
      else
        light [xyton(x,i)] = 3
      end
    else
      if up == 0 then
        light [xyton(x,i)] = 0
      else
        light [xyton(x,i)] = up-1
      end
    end
  end
end


function world.drawworld()
    for i = 1,world.l do
        io.write(world[i] or ' ')
        if i%world.w == 0 then print () end
    end
end

scrx = 1
scrspeed = 25

function world.drawscreen(k,p)
  p = p or 1
  k = math.floor(k) -- это ширина, или количество блоков по горизонтали
  if k > world.w or k < 1 then
    if debug>=1 then
      print('drawscreen error')
    end
    return
  end
  for x = 1 , k do
    -- 1 , world.w
    if p+k<= world.w then
      if x/k >= p/world.w and x/k <= (p+k)/world.w then
        io.write('=')
      else
        io.write('-')
      end
    else
      if x/k >= p/world.w or x/k <= (p+k)%world.w/world.w then
        io.write('=')
      else
        io.write('-')
      end
    end
  end
  print()
  for y = 1 , world.h do
    for x = p , p+k do
      if x > world.w then
        x = x - world.w
      end
      io.write(get(x,y))
    end
    print()
  end
end

function world.createseeds(s)
    n = tonumber((s or {})[2] or 1)
    for i = 1,n do
        local x,y = math.random(1,world.w),math.random(1,world.h-2)
        seed.create(x,y)
    end
end

--[[world.create(42,24)

for i = 1,5 do
    set(i,3,"d")
    
    set(i,4,"j")
    
    set(i,6,"l")
    
    set(i,8,"n")
    
end

world.resetlight2()
world.drawlight1()
world.drawworld()]]

--print (world.ntoxy(6))