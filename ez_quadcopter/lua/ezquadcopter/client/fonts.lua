local ratio = ScrW()/640
local sizes = {20, 30, 40}

function easzy.quadcopter.CreateFont(name, font, size, options)
    local name = (name or "NewFont") .. size
    local options = options or {}
    options.size = ScreenScale(size/ratio)
    options.font = font
    options.antialias = true
    options.shadow = false

    surface.CreateFont(name, options)
    return name
end

function easzy.quadcopter.CreateFonts(name, font, sizes, options)
    local names = {}
    for _, size in ipairs(sizes) do
        table.insert(names, easzy.quadcopter.CreateFont(name, font, size, options))
    end
    return names
end

-- Modern font with fallback
local function CreateFontWithFallback(fontName, size, weight)
    weight = weight or 400
    
    -- Try modern font first
    surface.CreateFont(fontName, {
        font = "Roboto",
        size = ScreenScale(size/ratio),
        weight = weight,
        antialias = true,
        shadow = false,
        outline = false
    })
    
    -- Test if font was created successfully
    surface.SetFont(fontName)
    local testW, testH = surface.GetTextSize("Test")
    
    if testW <= 0 then
        -- Fallback to Tahoma
        surface.CreateFont(fontName, {
            font = "Tahoma",
            size = ScreenScale(size/ratio),
            weight = weight,
            antialias = true,
            shadow = false
        })
    end
    
    -- If still doesn't work, use default system font
    surface.SetFont(fontName)
    testW, testH = surface.GetTextSize("Test")
    if testW <= 0 then
        surface.CreateFont(fontName, {
            font = "DermaDefault",
            size = ScreenScale(size/ratio),
            weight = weight,
            antialias = true,
            shadow = false
        })
    end
end

-- Create original fonts for compatibility
easzy.quadcopter.CreateFonts("EZFont", "Gidole", sizes)

-- Create additional modern fonts
for _, size in ipairs(sizes) do
    CreateFontWithFallback("EZFont" .. size, size, 400)
    CreateFontWithFallback("EZFontBold" .. size, size, 600)
end

-- Create extra sizes that might be needed
local extraSizes = {16, 18, 24, 28, 32, 36, 48}
for _, size in ipairs(extraSizes) do
    CreateFontWithFallback("EZFont" .. size, size, 400)
    CreateFontWithFallback("EZFontBold" .. size, size, 600)
end

hook.Add("OnScreenSizeChanged", "ezquadcopter_fonts_OnScreenSizeChanged", function()
    ratio = ScrW()/640
    easzy.quadcopter.CreateFonts("EZFont", "Gidole", sizes)
    
    -- Recreate additional fonts
    for _, size in ipairs(sizes) do
        CreateFontWithFallback("EZFont" .. size, size, 400)
        CreateFontWithFallback("EZFontBold" .. size, size, 600)
    end
    
    local extraSizes = {16, 18, 24, 28, 32, 36, 48}
    for _, size in ipairs(extraSizes) do
        CreateFontWithFallback("EZFont" .. size, size, 400)
        CreateFontWithFallback("EZFontBold" .. size, size, 600)
    end
end)