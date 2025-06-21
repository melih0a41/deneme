local ratio = ScrW()/640
local sizes = {20, 30, 40}

function easzy.quadcopter.CreateFont(name, font, size, options)
    local name = (name or "NewFont") .. size
    local options = options or {}
    options.size = ScreenScale(size/ratio)
    options.font = font

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

easzy.quadcopter.CreateFonts("EZFont", "Gidole", sizes)

hook.Add("OnScreenSizeChanged", "ezquadcopter_fonts_OnScreenSizeChanged", function()
	ratio = ScrW()/640
    easzy.quadcopter.CreateFonts("EZFont", "Gidole", sizes)
end)
