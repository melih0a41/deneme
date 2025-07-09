/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

local Game = {}

/*
	Called once the minigame starts
*/
function Game:OnStart(Machine,ply)
	// Once someone responds to the minigame we remove the default fail.
	// NOTE We wanna give the player as much time as possible for it but we need to make sure the machien doesent softlock one the player disconnects or dies
	if SERVER then

		// Remove fail timer
		zclib.Timer.Remove("zmlab2_MiniGame_" .. Machine:EntIndex())

		// If the minigame was not completed in 50 seconds then we consider this a fail
		local timerid = "zmlab2_Fallback_" .. Machine:EntIndex()
		zclib.Timer.Remove(timerid)
		zclib.Timer.Create(timerid,50,1,function()
			if IsValid(Machine) then
				zmlab2.MiniGame.Reset(Machine)
				zmlab2.MiniGame.Punishment(Machine,Machine:GetMethType())
			end
		end)
	end
end

/*
	Creates the interface
*/
function Game:Interface(Machine,ply)

	local difficulty = zmlab2.Meth.GetDifficulty(Machine:GetMethType())
	local duration = 30
	local MiniGameStart = CurTime()
	local GameDuration = Lerp((1/10) * difficulty,duration,duration * 0.3)
	local DeathTime = MiniGameStart + GameDuration

	local Symbols = {
		[ 1 ] = "zerochain/zmlab2/ui/callback_symbols/symbol01.png",
		[ 2 ] = "zerochain/zmlab2/ui/callback_symbols/symbol02.png",
		[ 3 ] = "zerochain/zmlab2/ui/callback_symbols/symbol03.png",
		[ 4 ] = "zerochain/zmlab2/ui/callback_symbols/symbol04.png",
		[ 5 ] = "zerochain/zmlab2/ui/callback_symbols/symbol05.png",
		[ 6 ] = "zerochain/zmlab2/ui/callback_symbols/symbol06.png",
		[ 7 ] = "zerochain/zmlab2/ui/callback_symbols/symbol07.png",
		[ 8 ] = "zerochain/zmlab2/ui/callback_symbols/symbol08.png",
		[ 9 ] = "zerochain/zmlab2/ui/callback_symbols/symbol09.png",
		[ 10 ] = "zerochain/zmlab2/ui/callback_symbols/symbol10.png",
	}

	local main = vgui.Create("DFrame")
	main:SetSize(800 * zclib.wM, 840 * zclib.hM)
	main:Center()
	main:MakePopup()
	main:ShowCloseButton(false)
	main:SetTitle("")
	main:SetDraggable(true)
	main:SetSizable(false)
	main:DockPadding(20 * zclib.wM, 20 * zclib.hM, 20 * zclib.wM, 20 * zclib.hM)

	main.MinigameSuccess = false

	main.Paint = function(s, w, h)
		surface.SetDrawColor(zmlab2.colors[ "blue02" ])
		surface.SetMaterial(zclib.Materials.Get("item_bg"))
		surface.DrawTexturedRect(0 * zclib.wM, 0 * zclib.hM, w, h)
		zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, color_white)
	end


	local SymbolTypes = {}

	for k, v in pairs(Symbols) do
		table.insert(SymbolTypes, {
			id = k,
			img = v,
			mat = Material("materials/" .. v, "noclamp")
		})
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	local CurrentSymbolStage = 1

	-- Generate list of Symbol ids we need to click on
	local SymbolsToClick = {}

	for i = 1, 5 do
		local dat = table.Random(SymbolTypes)
		table.insert(SymbolsToClick, dat)
	end

	local code_over_pnl = vgui.Create("DPanel", main)
	code_over_pnl:Dock(TOP)
	code_over_pnl:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 10 * zclib.hM)
	code_over_pnl:SetHeight(155 * zclib.hM)
	code_over_pnl.Paint = function(s, w, h)

		if input.IsKeyDown(KEY_ESCAPE) then
			main:Remove()
		end

		draw.RoundedBox(0, 0, 0, w, h, zclib.colors[ "black_a100" ])
		zclib.util.DrawOutlinedBox(0 * zclib.wM, 0, w, h, 2, zclib.colors[ "black_a100" ])

		if CurrentSymbolStage >= 6 then
			draw.SimpleText(zmlab2.language["Won"],zclib.GetFont("zclib_font_big"), w / 2, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

			main.MinigameSuccess = true
			
			if s.Fading == nil then

				zmlab2.MiniGame.Finish(self.GameID,Machine,true)

				if IsValid(main) then
					main:Remove()
				end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

				s.Fading = true
			end
		end

		local size = (w * 0.9) / 5

		for k, v in pairs(SymbolsToClick) do

			surface.SetDrawColor(CurrentSymbolStage <= k and zclib.colors[ "black_a100" ] or color_white)
			surface.SetMaterial(v.mat)
			surface.DrawTexturedRect(w * 0.055 + k * size * 0.99 - size, 10 * zclib.hM, size, size)

			if k == CurrentSymbolStage then
				surface.SetDrawColor(Color(255,255,255,math.abs(math.sin(CurTime() * 4)) * 25))
				surface.SetMaterial(v.mat)
				surface.DrawTexturedRect(w * 0.055 + k * size * 0.99 - size, 10 * zclib.hM, size, size)
			end
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf

	local time_pnl = vgui.Create("DPanel", main)
	time_pnl:Dock(TOP)
	time_pnl:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 10 * zclib.hM)
	time_pnl:SetHeight(8 * zclib.hM)
	time_pnl.GameDuration = GameDuration
	time_pnl.DeathTime = DeathTime
	time_pnl.Paint = function(s, w, h)

		local time = math.Clamp(s.DeathTime - CurTime(), 0, s.GameDuration)

		if CurrentSymbolStage < 6 and time <= 0 and IsValid(main) then
			main:Close()
			zmlab2.MiniGame.Finish(self.GameID,Machine,false)
		end

		draw.RoundedBox(0, w / 2 - w / 2, 0, w, h , zclib.colors[ "black_a100" ])

		local newW = w / s.GameDuration * time
		draw.RoundedBox(0, w / 2 - newW / 2, 0, newW, h, zmlab2.colors["orange01"])
	end

	local button_over_container = vgui.Create("DPanel", main)
	button_over_container:Dock(TOP)
	button_over_container:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	button_over_container:SetHeight(300 * zclib.hM)
	button_over_container.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, zclib.colors[ "black_a100" ])
		zclib.util.DrawOutlinedBox(0 * zclib.wM, 0, w, h, 2, zclib.colors[ "black_a100" ])
	end

	local button_container = vgui.Create("DIconLayout", button_over_container)
	button_container:SetSize(750 * zclib.wM, 410 * zclib.hM)
	button_container:SetSpaceY(15 * zclib.hM)
	button_container:SetSpaceX(0 * zclib.wM)
	button_container:SetPos(10 * zclib.wM, 10 * zclib.hM)
	button_container.Paint = function(s, w, h)
		//draw.RoundedBox(0, 0, 0, w, h, zclib.colors[ "green01" ])
	end

	for k, v in ipairs(zclib.table.randomize(SymbolTypes)) do
		local btn_pnl = button_container:Add("DImageButton")
		btn_pnl:SetImage(v.img)
		btn_pnl:SetSize(149 * zclib.wM, 135 * zclib.hM)

		btn_pnl.Paint = function(s, w, h)
			s.Alpha = Lerp(FrameTime() * 10,s.Alpha or 0,s:IsHovered() and 1 or 0)
			s:SetColor(zclib.util.LerpColor(s.Alpha, color_white, zmlab2.colors["orange01"]))
		end

		btn_pnl.DoClick = function(s)
			zclib.vgui.PlaySound("UI/buttonclick.wav")

			if v.id == SymbolsToClick[ CurrentSymbolStage ].id then
				CurrentSymbolStage = CurrentSymbolStage + 1
			end
		end
	end

	main:InvalidateLayout(true)
	main:SizeToChildren(false, true)
	main:Center()

	main.OnRemove = function(s)
		
		if not main.MinigameSuccess then
			zmlab2.MiniGame.Finish(self.GameID, Machine, false)
		end
	end
end

/*
	Called once the minigame finishes
*/
function Game:OnFinish(Machine,ply,DidWin)
	if SERVER then
		// Fallback fail timer
		zclib.Timer.Remove("zmlab2_Fallback_" .. Machine:EntIndex())
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

zmlab2.MiniGame.Register("callback",Game)
