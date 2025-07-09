/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

local Game = {}

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
	window:SetSize(600 * zclib.wM, 200 * zclib.hM)
    window:Center()
    window:SetPos((ScrW() / 2) - 300 * zclib.wM,(ScrH() / 2) + 150 * zclib.wM)
    window:MakePopup()
    window:ShowCloseButton(false)
    window:SetTitle("")
    window:SetDraggable(true)
    window:SetSizable(false)

    window:DockMargin(0, 0, 0, 0)
    window:DockPadding( 10 * zclib.wM,10 * zclib.wM,10 * zclib.wM,10 * zclib.wM)

	window.Paint = function(s, w, h)
		surface.SetDrawColor(zmlab2.colors[ "blue02" ])
		surface.SetMaterial(zclib.Materials.Get("item_bg"))
		surface.DrawTexturedRect(0 * zclib.wM, 0 * zclib.hM, w, h)
		draw.SimpleText(zmlab2.language[ "SPACE" ], zclib.GetFont("zclib_font_big"), w / 2, 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, color_white)
	end

    window.PlayMusic = true
    window.MinigameSuccess = false

    local difficulty = 1
    if Machine.GetMethType then
        local dat = zmlab2.config.MethTypes[Machine:GetMethType()]
        difficulty = dat.difficulty
    end

	local MiniGame_Time = math.random(4,8)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

    // At which part of the bar is the safe area
    local safe_pos = (1 / 10) * MiniGame_Time
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    // The size of the safe area
    local safe_size = 1 - ((1 / 10) * difficulty)

    // The time in seconds
    local game_time = 1.5


    local safe_start = game_time * safe_pos
    local safe_mul = 0.1 + (0.1 * safe_size)
    local safe_end = safe_start + (game_time * safe_mul)

    local MainContainer = vgui.Create("DPanel", window)
    MainContainer:Dock(FILL)
    MainContainer:DockMargin(5,50,5,5)
    MainContainer.Paint = function(s, w, h)

        // The Size of the whole bar
        local max_length = w-10

        // The Size of the safe area, its 10% of the whole bar
        local safe_length = max_length * safe_mul

        local diff = CurTime() - MainContainer.CreationTime
        local pointer_pos = (max_length / game_time) * diff
        pointer_pos = math.Clamp(pointer_pos, 0, max_length)

        local CanWin = false
        if diff >= safe_start and diff < safe_end then
            CanWin = true
        end

        draw.RoundedBox(0, 0, 0, w, h, zclib.colors["black_a100"])

        draw.RoundedBox(0, 5, 5, w-10, h-10, zmlab2.colors["red02"])

        draw.RoundedBox(0, (max_length / game_time) * safe_start, 5 , safe_length, h - 10, zmlab2.colors["green03"])

        if CanWin then draw.RoundedBox(0, (max_length / game_time) * safe_start, 5, safe_length, h - 10, zmlab2.colors["white02"]) end

        draw.RoundedBox(0, 3 + pointer_pos, 5,6, h - 10, color_black)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

        surface.SetDrawColor(color_white)
        surface.SetMaterial(zclib.Materials.Get("errorgame_overlay"))
        surface.DrawTexturedRect(0 * zclib.wM, 0 * zclib.hM, w,h)
    end
    MainContainer.CreationTime = CurTime()
    MainContainer.DidAction = false
    MainContainer.Think = function(s)
        if input.IsKeyDown(KEY_ESCAPE) then
	        window:Close()
	    end
        
        if MainContainer.DidAction == false then

            // Safe area is 10%
            local f_WinArea = game_time * safe_mul
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

            local f_WinTime = game_time * safe_pos

            local f_CurTime = CurTime() - MainContainer.CreationTime

            // Did we win?
            local result = false
            if f_CurTime >= f_WinTime and f_CurTime < (f_WinTime + f_WinArea) then
                result = true
            end

            if input.IsKeyDown(KEY_SPACE) == true or f_CurTime > game_time then

                MainContainer.DidAction = true

                window.MinigameSuccess = result
				zmlab2.MiniGame.Finish(self.GameID,Machine,result)

				window.PlayMusic = false
			    if window.Sound and window.Sound:IsPlaying() == true then
			        window.Sound:Stop()
			    end
				window:Remove()
            end
        end

        if window.PlayMusic == true then
            if window.Sound == nil then
                window.Sound = CreateSound(Machine, "zmlab2_errorgame_loop")
            else
                if window.Sound:IsPlaying() == false then
                    window.Sound:Play()
                    window.Sound:ChangeVolume(1, 1)
                end
            end
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
end

zmlab2.MiniGame.Register("quicktime",Game)
