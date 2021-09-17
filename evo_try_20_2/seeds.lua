seed = {}

function seed.create(x,y,genom,energy)
    local a = {}
    a.x , a.y = x, y
    if genom==-1 or genom==nil then
        genom=genome.create()
    end
    a.genom = genom
    a.energy = energy or 260
    a.handle = seed.handle
    if debug>=1 then
        print ("created seed at "..x..", "..y)
    end
    seed[#seed+1]=a
end

function seed.destroy(a)
    local d = false
    for i = 1,#seed do
        if seed[i]==a then
            d = true
        end
        if d then
            seed[i]=seed[i+1]
        end
    end
end

function getseedcount()
    print ("seedcount = "..#seed)
end

