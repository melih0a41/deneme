/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

if SERVER then return end
zpiz = zpiz or {}
zpiz.Sign = zpiz.Sign or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70

function zpiz.Sign.Draw(Sign)
	if zclib.util.InDistance(LocalPlayer():GetPos(), Sign:GetPos(), 500) then
		zpiz.Sign.DrawMainInfo(Sign)
	end
end

function zpiz.Sign.DrawMainInfo(Sign)
	local status
	local sState = Sign:GetSignState()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

	if (sState) then
		status = zpiz.language.OpenSign_open
	else
		status = zpiz.language.OpenSign_closed
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

	cam.Start3D2D(Sign:GetPos(), zclib.HUD.GetLookAngles(), 0.1)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.SetMaterial(zpiz.materials["zpiz_button"])
		surface.DrawTexturedRect(-250, -360, 500, 80)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70

		if (sState) then
			surface.SetDrawColor(0, 0, 0, 100)
			surface.SetMaterial(zpiz.materials["zpiz_button"])
			surface.DrawTexturedRect(-150, -280, 300, 80)
			draw.DrawText(zpiz.language.OpenSign_Revenue .. zclib.Money.Display(Sign:GetSessionEarnings()), zclib.GetFont("zpiz_vgui_font03"), 0, -250, color_white, TEXT_ALIGN_CENTER)
		end

		draw.DrawText(status, zclib.GetFont("zpiz_plate_font02"), 0, -350, color_white, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
