/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

if SERVER then return end
zpiz = zpiz or {}
zpiz.Plate = zpiz.Plate or {}

CreateMaterial("zpiz_pizzaMat", "VertexLitGeneric", {
    ["$basetexture"] = "color/white",
    ["$model"] = 1,
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1e328fabbaf565eb0db586ac588b71f8384bcaa811ba77de699b4af9f3938eed
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

function zpiz.Plate.Initialize(Plate)
    Plate:SetMaterial("!zpiz_pizzaMat")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70

function zpiz.Plate.Draw(Plate)
    if zclib.util.InDistance(LocalPlayer():GetPos(), Plate:GetPos(), 500) and zpiz.Pizza.GetData(Plate:GetPizzaID()) then
        zpiz.Plate.DrawInfo(Plate)
    end
end

local offset = Vector(0, 0, 25)
function zpiz.Plate.DrawInfo(Plate)
    local time = Plate:GetPizzaWaitTime()

    if (time > 0) then

        local pizzaID = Plate:GetPizzaID()
        local pName = zpiz.Pizza.GetName(pizzaID)
        local charlength = string.len(pName)

        local maxTime = zpiz.Pizza.GetBakeTime(pizzaID) + zpiz.config.Customer.ExtraWaitTime

        time = math.Round(time - CurTime())
        local progress = (1 / maxTime) * time
        local c = zclib.util.LerpColor(progress, Color(255, 0, 0, 255), Color(0, 255, 0, 255))

        cam.Start3D2D(Plate:GetPos() + Plate:GetUp() * math.abs(math.sin(CurTime() * 2) * 5) + offset , zclib.HUD.GetLookAngles(), 0.1)

            surface.SetDrawColor( 0, 0, 0, 100 )
            surface.SetMaterial( zpiz.materials["zpiz_button"] )
            surface.DrawTexturedRect( -50, -410, 100, 80 )

            draw.DrawText(time, zclib.GetFont("zpiz_plate_font02"),0, -415,  c, TEXT_ALIGN_CENTER  )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

            surface.SetDrawColor( c )
            surface.SetMaterial( zpiz.materials["zpiz_arrow"] )
            surface.DrawTexturedRect( -70, -100, 140, 140 )

            draw.RoundedBox(5, -(25 * charlength)  / 2, -170, 25 * charlength, 50, zpiz.colors["black02"])
            draw.DrawText(pName, zclib.GetFont("zpiz_pizza_font01"),0, -170,  color_white, TEXT_ALIGN_CENTER  )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1e328fabbaf565eb0db586ac588b71f8384bcaa811ba77de699b4af9f3938eed

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( zpiz.materials["zpiz_clock_base"] )
            surface.DrawTexturedRect( -90, -360, 180, 180 )

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( zpiz.materials["zpiz_clock_pointer"] )
            surface.DrawTexturedRectRotated( 0, -270, 180, 180 ,  Lerp(progress, 0 ,360) )
        cam.End3D2D()
    end
end
