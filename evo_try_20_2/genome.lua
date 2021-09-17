genome={}
function genome. create ()
    local a = {}
    for i = 1,16 do
        a[i]={}
        for j = 1,4 do
            a[i][j]=math.random(1,32)
        end
    end
    a.mutate = genome.mutate
    a.draw = genome.draw
    return a
end
function genome.mutate(a)
    local g = {}
    for i = 1,16 do
      g[i] = {}
      for j = 1,4 do
        g[i][j]=a[i][j]
      end
    end
    g.mutate = genome.mutate
    g.draw = genome.draw
    for i = 1,math.random(1,2) do
        local c,d = math.random(1,16),math.random(1,4)
        g[c][d]=(g[c][d]+math. random (1,16))%32+1
    end
    return g
end

function genome.draw(a)
    for i = 1,16 do
        io.write(i..": ")
        for j=1,4 do
            io.write(a[i][j]..", ")
        end
        print ()
    end
end

--[[g = genome.create()
g:draw()
print"------------:--:--------"
m = g:mutate()
m:draw()]]