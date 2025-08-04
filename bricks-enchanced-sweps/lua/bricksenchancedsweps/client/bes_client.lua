local function GetImageFromID( URL )
    local CRC = util.CRC( URL )

    local Extension = string.Split( URL, "." )
    Extension = Extension[#Extension] or "png"

    if( not file.Exists( "bricksenchancedsweps/images", "DATA" ) ) then
        file.CreateDir( "bricksenchancedsweps/images" )
    end
    
    if( file.Exists( "bricksenchancedsweps/images/" .. CRC .. "." .. Extension, "DATA" ) ) then
        return Material( "data/bricksenchancedsweps/images/" .. CRC .. "." .. Extension, "noclamp smooth" )
    else
        http.Fetch( URL, function( body )
            file.Write( "bricksenchancedsweps/images/" .. CRC .. "." .. Extension, body )
            return Material( "data/bricksenchancedsweps/images/" .. CRC .. "." .. Extension, "noclamp smooth" )
        end )
    end
end

BES.CachedMaterials = {}

function BES.GetImage( URL, dontContinue )
    if( not isstring( URL ) ) then return Material( "" ) end

    local CRC = util.CRC( URL )

    if( BES.CachedMaterials[CRC] and type( BES.CachedMaterials[CRC] ) == "IMaterial" ) then
        return BES.CachedMaterials[CRC], URL
    elseif( not dontContinue and not BES.CachedMaterials[CRC] ) then
        BES.CachedMaterials[CRC] = GetImageFromID( URL )
        return BES.GetImage( CRC, true )
    else
        return Material( "" )
    end
end

surface.CreateFont( "BES_Myriad_38", {
    font = "MyriadPro-Bold",
    size = 38,
    weight = 500,
} )

surface.CreateFont( "BES_Myriad_24", {
    font = "MyriadPro-Bold",
    size = 24,
    weight = 500,
} )

surface.CreateFont( "BES_UniSans_15", {
    font = "Uni Sans Heavy CAPS",
    size = 15,
    weight = 500,
} )

surface.CreateFont( "BES_UniSans_30", {
    font = "Uni Sans Heavy CAPS",
    size = 30,
    weight = 500,
} )

surface.CreateFont( "BES_Calibri_21", {
    font = "Calibri",
    size = 21,
    weight = 500,
} )

surface.CreateFont( "BES_Calibri_19", {
    font = "Calibri",
    size = 19,
    weight = 500,
} )

surface.CreateFont( "BES_Calibri_16", {
    font = "Calibri",
    size = 16,
    weight = 500,
} )

-- Draws an arc on your screen.
-- startang and endang are in degrees, 
-- radius is the total radius of the outside edge to the center.
-- cx, cy are the x,y coordinates of the center of the arc.
-- roughness determines how many triangles are drawn. Number between 1-360; 2 or 3 is a good number.
function draw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color)
    surface.SetDrawColor(color)
	draw.NoTexture()
    surface.DrawArc(surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness))
end

function surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness)
    local triarc = {}
    -- local deg2rad = math.pi / 180
    
    -- Define step
    local roughness = math.max(roughness or 1, 1)
    local step = roughness
    
    -- Correct start/end ang
    local startang,endang = startang or 0, endang or 0
    
    if startang > endang then
        step = math.abs(step) * -1
    end
    
    -- Create the inner circle's points.
    local inner = {}
    local r = radius - thickness
    for deg=startang, endang, step do
        local rad = math.rad(deg)
        -- local rad = deg2rad * deg
        local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
        table.insert(inner, {
            x=ox,
            y=oy,
            u=(ox-cx)/radius + .5,
            v=(oy-cy)/radius + .5,
        })
    end	
    
    -- Create the outer circle's points.
    local outer = {}
    for deg=startang, endang, step do
        local rad = math.rad(deg)
        -- local rad = deg2rad * deg
        local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
        table.insert(outer, {
            x=ox,
            y=oy,
            u=(ox-cx)/radius + .5,
            v=(oy-cy)/radius + .5,
        })
    end	
    
    -- Triangulize the points.
    for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
        local p1,p2,p3
        p1 = outer[math.floor(tri/2)+1]
        p3 = inner[math.floor((tri+1)/2)+1]
        if tri%2 == 0 then --if the number is even use outer.
            p2 = outer[math.floor((tri+1)/2)]
        else
            p2 = inner[math.floor((tri+1)/2)]
        end
    
        table.insert(triarc, {p1,p2,p3})
    end
    
    -- Return a table of triangles to draw.
    return triarc
end

function surface.DrawArc(arc) //Draw a premade arc.
    for k,v in ipairs(arc) do
        surface.DrawPoly(v)
    end
end

local g_grds, g_wgrd, g_sz
function draw.GradientBox(x, y, w, h, al, ...)
    g_grds = {...}
    al = math.Clamp(math.floor(al), 0, 1)
    if(al == 1) then
        local t = w
        w, h = h, t
    end
    g_wgrd = w / (#g_grds - 1)
    local n
    for i = 1, w do
        for c = 1, #g_grds do
            n = c
            if(i <= g_wgrd * c) then
                break
            end
        end
        g_sz = i - (g_wgrd * (n - 1))
        surface.SetDrawColor(
            Lerp(g_sz/g_wgrd, g_grds[n].r, g_grds[n + 1].r),
            Lerp(g_sz/g_wgrd, g_grds[n].g, g_grds[n + 1].g),
            Lerp(g_sz/g_wgrd, g_grds[n].b, g_grds[n + 1].b),
            Lerp(g_sz/g_wgrd, g_grds[n].a, g_grds[n + 1].a))
        if(al == 1) then
            surface.DrawRect(x, y + i, h, 1)
        else
            surface.DrawRect(x + i, y, 1, h)
        end
    end
end