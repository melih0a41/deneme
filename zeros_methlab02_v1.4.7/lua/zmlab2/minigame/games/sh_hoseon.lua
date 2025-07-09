/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

local Game = {}

/*

	This MiniGame will only be used for the Mixer to add the Ventilation hose and wont show up in the random minigames

*/

// We dont want this minigame to appear in the random selection
Game.IgnoreRandom = true

// Prevents a fail timer from being created
Game.SkipFailTimer = true


/*
	Called once the minigame starts
*/
function Game:OnStart(Machine,ply)
end

/*
	Creates the interface
*/
function Game:Interface(Machine,ply)

	local window = vgui.Create("DFrame")
	window:SetSize(600 * zclib.wM, 750 * zclib.hM)
    window:Center()
    window:MakePopup()
    window:ShowCloseButton(false)
    window:SetTitle("")
    window:SetDraggable(true)
    window:SetSizable(false)
    window:DockPadding(0, 0, 0, 0)

    // The allowed deviation from the center point
    window.ErrorMargin = 0.2

    // The default distance to the goal
    window.DistanceToGoal = 0.25

    if IsValid(Machine) and Machine:GetClass() == "zmlab2_machine_mixer" then
        local difficulty = zmlab2.Meth.GetDifficulty(Machine:GetMethType())

        local DiffChange = (1 / 10) * (10 - difficulty)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        window.ErrorMargin = window.ErrorMargin + (0.2 * DiffChange)

        window.DistanceToGoal = window.DistanceToGoal - (0.25 * DiffChange)
    end

    window.StartTime = CurTime()
    window.PosX = 0
    window.PosY = 0
    window.IsFalling = false
    window.IsAnimating = false
    window.FallValue = 0
    window.PlayMusic = true
	window.MinigameSuccess = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	window.Paint = function(s,w, h)
	    surface.SetDrawColor(zmlab2.colors["blue02"])
	    surface.SetMaterial(zclib.Materials.Get("item_bg"))
	    surface.DrawTexturedRect(0 * zclib.wM, 0 * zclib.hM, w, h)
	    local size = h * 1.2
	    local newX = (w * 0.5) + (w * 0.4) * window.PosX

	    if window.IsFalling or window.IsAnimating then
	        window.PosY = (-size * window.DistanceToGoal) + ((size * (0.325 + window.DistanceToGoal)) * window.FallValue)
	    else
	        window.PosY = -size * window.DistanceToGoal
	    end

	    surface.SetDrawColor(color_white)
	    surface.SetMaterial(zclib.Materials.Get("long_pipe"))
	    surface.DrawTexturedRectRotated(newX, window.PosY, size, size, 0)

	    if window.IsAnimating == false then
	        surface.SetDrawColor(color_white)
	        local rot = 15 * math.sin(CurTime() * 6)
	        rot = zclib.util.SnapValue(15, rot)

	        if rot == 15 then
	            surface.SetMaterial(zclib.Materials.Get("pipe_smoke02"))
	        elseif rot == 0 then
	            surface.SetMaterial(zclib.Materials.Get("pipe_smoke01"))
	        elseif rot == -15 then
	            surface.SetMaterial(zclib.Materials.Get("pipe_smoke03"))
	        end

	        surface.DrawTexturedRectRotated(w / 2, h - 110 * zclib.hM, 220 * zclib.wM, 220 * zclib.hM, 0)
	    end

	    if window.IsAnimating == false and window.IsFalling == false then
	        draw.SimpleText(zmlab2.language["SPACE"], zclib.GetFont("zclib_font_big"), w / 2, h * 0.75, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	        local barSize = w * window.ErrorMargin
	        if math.abs(window.PosX) < window.ErrorMargin then
	            draw.RoundedBox(5, w / 2 - barSize / 2, h - 165 * zclib.hM, barSize, 10 * zclib.hM, color_white)
	        else
	            draw.RoundedBox(5, w / 2 - barSize / 2, h - 165 * zclib.hM, barSize, 10 * zclib.hM, zclib.colors["black_a200"])
	        end
	    else
	        surface.SetDrawColor(color_white)
	        surface.SetMaterial(zclib.Materials.Get("pipe_connect"))
	        surface.DrawTexturedRectRotated(w / 2, h - 110 * zclib.hM, 220 * zclib.wM, 220 * zclib.hM, 0)
	    end

	    zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, color_white)
	end

	window.ShowResult = function(s, WeWon)

	    window.IsAnimating = true

	    // Snap to center so it fits better
	    if WeWon then
	        window.PosX = 0
	    end

	    if WeWon then
	        surface.PlaySound("zmlab2/minigame_won.wav")
	    else
	        surface.PlaySound("zmlab2/minigame_lost.wav")
	    end

	    local MainContainer = vgui.Create("DPanel", window)
	    MainContainer:SetAlpha(0)
	    MainContainer:Dock(FILL)

	    MainContainer.Paint = function(s, w, h)
	        draw.RoundedBox(0, 0, 0, w, h, zclib.colors["black_a200"])
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf

	        if WeWon then
	            draw.SimpleText(zmlab2.language["Connected"], zclib.GetFont("zclib_font_large"), w / 2, h / 2, zmlab2.colors["green03"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	        else
	            draw.SimpleText(zmlab2.language["Missed"], zclib.GetFont("zclib_font_large"), w / 2, h / 2, zmlab2.colors["red02"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	        end
	    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

		window.MinigameSuccess = WeWon

	    MainContainer:AlphaTo(255, 0.25, 0, function()
	        timer.Simple(1, function()
	            if not IsValid(window) then return end

				zmlab2.MiniGame.Finish(self.GameID, Machine, WeWon)

	            window:Close()
	        end)
	    end)
	end

	window.Think = function()
	    if window.IsFalling == false and window.IsAnimating == false and input.IsKeyDown(KEY_ESCAPE) then
	        window:Close()
	    end

	    if window.PlayMusic == true then
	        if window.Sound == nil then
				if not IsValid(Machine) then return end
	            window.Sound = CreateSound(Machine, "zmlab2_minigame_loop")
	        else
	            if window.Sound:IsPlaying() == false then
	                window.Sound:Play()
	                window.Sound:ChangeVolume(1, 1)
	            end
	        end
	    else
	        if window.Sound and window.Sound:IsPlaying() == true then
	            window.Sound:Stop()
	        end
	    end

	    if window.IsAnimating == true then return end

	    if window.IsFalling then
	        local passed = CurTime() - window.StartTime
	        window.FallValue = math.Clamp((1 / 0.5) * passed, 0, 1)
	        window.FallValue = math.EaseInOut(window.FallValue, 1, 0)

	        // If we reached the endpipe lets check if the value was correct
	        if window.FallValue >= 1 then
	            window.IsFalling = false

	            if math.abs(window.PosX) < window.ErrorMargin then
	                // We won!
	                window:ShowResult(true)
	            else
	                // We missed!
	                window:ShowResult(false)
	            end
	        end
	    else
	        window.PosX = math.sin(CurTime() * 2)
	    end

	    if window.IsAnimating == false and input.IsKeyDown(KEY_SPACE) then
	        window.StartTime = CurTime()
	        window.IsFalling = true
	        surface.PlaySound("zmlab2/minigame_hit.wav")
	        window.PlayMusic = false
	    end
	end

	window.Close = function()
	    window.PlayMusic = false
	    if window.Sound and window.Sound:IsPlaying() == true then window.Sound:Stop() end

	    if IsValid(window) then
	        window:Remove()
	    end

	    if window.Sound and window.Sound:IsPlaying() == true then
	        window.Sound:Stop()
	    end
	end

	window.OnRemove = function(s)
		
		if not window.MinigameSuccess then
			zmlab2.MiniGame.Finish(self.GameID, Machine, false)
		end
	end
end

/*
	Called once the minigame finishes
*/
function Game:OnFinish(Machine,ply,DidWin)

	if SERVER then
	    if not DidWin then 
			zmlab2.MiniGame.Punishment(Machine, Machine:GetMethType())
		end

	    zmlab2.Mixer.VentGame_Completed(Machine)
	end
end

/*
	Can be used to overwrite the error screen
*/
function Game:OverwriteErrorScreen(Machine)

	surface.SetDrawColor(zmlab2.colors[ "blue02" ])
	surface.SetMaterial(zclib.Materials.Get("item_bg"))
	surface.DrawTexturedRectRotated(0, 0, 220, 280, 0)

	local rot = 10 * math.sin(CurTime() * 1)
	rot = zclib.util.SnapValue(15,rot)

	surface.SetDrawColor(color_white )
	if rot == 0 then
		surface.SetMaterial(zclib.Materials.Get("icon_pipe"))
	else
		surface.SetMaterial(zclib.Materials.Get("icon_pipe_smoke"))
	end
	surface.DrawTexturedRectRotated(0, 10, 260, 260, 0 )

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf

	local e_width,e_y = 100,-45
	surface.SetDrawColor(color_white)
	surface.SetMaterial(zclib.Materials.Get("icon_E"))
	surface.DrawTexturedRectRotated(0, e_y, e_width, e_width, 0)

	if Machine:OnCenterButton(LocalPlayer()) then
		draw.RoundedBox(10, -45, -90, 90, 90, zmlab2.colors["white02"])
	end

	Machine.Pulse = (Machine.Pulse or 0) + (1 * FrameTime())
	if Machine.Pulse > 1 then Machine.Pulse = 0 end

	local mul = 1 + math.abs(0.7 * Machine.Pulse)
	surface.SetDrawColor(Color(255, 255, 255, 200 - 200 * Machine.Pulse))
	surface.SetMaterial(zclib.Materials.Get("icon_box01"))
	surface.DrawTexturedRectRotated(0, e_y, e_width * mul, e_width * mul, 0)
end

zmlab2.MiniGame.Register("hoseon",Game)
