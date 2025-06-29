local cAccentColor = gScooters.Config.AccentColor

function gScooters:ChatMessage(sMessage)
    surface.PlaySound("gscooters/notify.wav")

    chat.AddText(cAccentColor, "gScooters", Color(121, 121, 121), " » ", color_white, sMessage)
end

net.Receive("gScooters.Net.ChatMessage", function()
    gScooters:ChatMessage(net.ReadString())
end)

