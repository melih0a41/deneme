local function createFont(name, size)
    surface.CreateFont(name, {
        font = "Roboto Lt",
        size = Corporate_Takeover.Scale(size),
        weight = 500,
        antialias = true,
    })
end

createFont("cto_50", 50)
createFont("cto_40", 40)
createFont("cto_30", 30)
createFont("cto_25", 25)
createFont("cto_24", 20)
createFont("cto_22", 20)
createFont("cto_20", 20)
createFont("cto_18", 18)
createFont("cto_15", 15)