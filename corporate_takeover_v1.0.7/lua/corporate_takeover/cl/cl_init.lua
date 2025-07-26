local scrH = ScrH
function Corporate_Takeover.Scale(value)
    return value * (scrH() / 1080)
end

net.Receive("cto_sync", function()
    local type = net.ReadUInt(5)

    if type == 1 then -- Sync Corps
        local len = net.ReadUInt(32)
        local compressed = net.ReadData(len)
        Corporate_Takeover.Corps = util.JSONToTable(util.Decompress(compressed))
    elseif type == 2 then -- Sync Corp
        local CorpID = net.ReadUInt(8)
        local len = net.ReadUInt(32)
        local compressed = net.ReadData(len)
        local data = util.JSONToTable(util.Decompress(compressed))

        local Corp = Corporate_Takeover.Corps[CorpID]
        if(Corp) then
            Corporate_Takeover.Corps[CorpID] = data
        end
    elseif type == 3 then -- Sync Money and Level
        local CorpID = net.ReadUInt(8)
        local data = {
            money = net.ReadInt(32),
            maxMoney = net.ReadUInt(32),
            level = net.ReadUInt(5),
            xp = net.ReadUInt(32),
            xpNeeded = net.ReadUInt(32)
        }

        local Corp = Corporate_Takeover.Corps[CorpID]
        if(Corp) then
            Corporate_Takeover.Corps[CorpID].money = data.money
            Corporate_Takeover.Corps[CorpID].maxMoney = data.maxMoney
            Corporate_Takeover.Corps[CorpID].level = data.level
            Corporate_Takeover.Corps[CorpID].xp = data.xp
            Corporate_Takeover.Corps[CorpID].xpNeeded = data.xpNeeded
        end
    elseif type == 4 then -- Sync Desks
        local CorpID = net.ReadUInt(8)
        local len = net.ReadUInt(32)
        local compressed = net.ReadData(len)
        local data = util.JSONToTable(util.Decompress(compressed))

        local Corp = Corporate_Takeover.Corps[CorpID]
        if(Corp) then
            Corporate_Takeover.Corps[CorpID].desks = data
        end
    elseif type == 5 then -- Sync Workers
        local CorpID = net.ReadUInt(8)
        local len = net.ReadUInt(32)
        local compressed = net.ReadData(len)
        local data = util.JSONToTable(util.Decompress(compressed))

        local Corp = Corporate_Takeover.Corps[CorpID]
        if(Corp) then
            Corporate_Takeover.Corps[CorpID].workers = data
        end
    elseif type == 6 then -- Sync Researches
        local CorpID = net.ReadUInt(8)
        local len = net.ReadUInt(32)
        local compressed = net.ReadData(len)
        local data = util.JSONToTable(util.Decompress(compressed))

        local Corp = Corporate_Takeover.Corps[CorpID]
        if(Corp) then
            Corporate_Takeover.Corps[CorpID].researches = data
        end
    end
end)


// Global blueprint entity
local DeskBlueprint
local color_transparent_black = Color(0, 0, 0, 150)
local placement_allowed = Color(50,255,50,150)
local placement_not_allowed = Color(255,50,50,150)

function Corporate_Takeover.PlaceDesk(builder)
    hook.Remove("Think", "cto_think_clientprop")
    hook.Remove("HUDPaint", "cto_display_instructions")
    
    if(builder) then
        local ply = LocalPlayer()
        local DeskClass = builder:GetDeskClass()
        DeskBlueprint = Corporate_Takeover:GetDesk(DeskClass)
        if(!DeskBlueprint) then
            return false
        end

        local prop = ents.CreateClientProp()
        prop:SetPos( ply:GetPos() )
        prop:SetModel(DeskBlueprint.model || "models/corporate_takeover/nostras/worker_desk.mdl")
        prop:SetMaterial("models/debug/debugwhite")
        prop:SetRenderMode(4)
        prop:SetColor(placement_allowed)
        prop:Spawn()

        // Cancel placement and remove blueprint prop
        local function cancelPlacement(playSound)
        	net.Start("cto_deskPlacement")
                net.WriteBit(0)
        	net.SendToServer()

            if(IsValid(prop)) then
                prop:Remove()
            end

            hook.Remove("Think", "cto_think_clientprop")
            hook.Remove("HUDPaint", "cto_display_instructions")
            if(playSound) then
            	ply:EmitSound(Corporate_Takeover.Config.Sounds.General["deskplacer_aborted"])
            end
        end

        local soundDelay = CurTime()

        hook.Add("HUDPaint", "cto_display_instructions", function()
            local w, h = ScrW(), ScrH()
            local x, y = w/2, h*.6

            surface.SetFont("cto_30")

            local text1 = Corporate_Takeover:Lang("key_place_desk")//"LMB: Place desk"
            local ts1 = surface.GetTextSize(text1)

            local text2 = Corporate_Takeover:Lang("key_cancel_desk")//"RMB: Cancel"
            local ts2 = surface.GetTextSize(text2)

            local _w = ts1
            if(ts2 > ts1) then
                _w = ts2
            end
            _w = _w + 20

            draw.RoundedBox(10,w/2 -(_w/2),y-10,_w,80,color_transparent_black)
            draw.SimpleText(text1, "cto_30", x+1, y+1, color_black, TEXT_ALIGN_CENTER)
            draw.SimpleText(text1, "cto_30", x, y, color_white, TEXT_ALIGN_CENTER)

            y = y + 30

            draw.SimpleText(text2, "cto_30", x+1, y+1, color_black, TEXT_ALIGN_CENTER)
            draw.SimpleText(text2, "cto_30", x, y, color_white, TEXT_ALIGN_CENTER)
        end)

        local vector_up = Vector(0, 0, 100)
        local vector_one = Vector(0, 0, 1)
        hook.Add("Think", "cto_think_clientprop", function()
            if(!IsValid(prop) or !ply:Alive()) then
                cancelPlacement(false)
                return false
            end
            if(prop && IsValid(prop)) then
                // Always be able to cancel it
                if input.IsMouseDown(MOUSE_RIGHT) then
                    cancelPlacement(false) 
                end

                // Get pos where the player looks at
                local tr = ply:GetEyeTrace()
                local ang = ply:GetAngles()

                local trace = {}
                trace.start = tr.HitPos
                trace.endpos = trace.start - vector_up
                trace.filter = prop

                tr = util.TraceLine(trace)

                // Found pos
                if tr.Hit then
                  prop:SetPos(tr.HitPos + tr.HitNormal * DeskBlueprint.modeloffset + vector_one)
                end

                prop:SetAngles(Angle(0, ang.y + DeskBlueprint.modelang, 0))

                // Check if the position is valid
                local can = Corporate_Takeover:CanPlaceDeskHere(ply, prop, builder)

                // LMB = Place
                if(input.IsMouseDown(MOUSE_LEFT)) then
                	if(can) then
	                    net.Start("cto_deskPlacement")
                            net.WriteBit(1)
	                        net.WriteVector(prop:GetPos())
	                        net.WriteAngle(prop:GetAngles())
	                    net.SendToServer()
	                    cancelPlacement(false) 
                	else
                		if(soundDelay < CurTime()) then
                			soundDelay = CurTime() + .5
                			ply:EmitSound("buttons/combine_button1.wav")
                		end
                	end
                end

                if(can) then
                    prop:SetColor(placement_allowed)
                else
                    prop:SetColor(placement_not_allowed)
                end
            end
        end)
    end
end
net.Receive("cto_OpenDeskBuilder", function()
    local builder = net.ReadEntity()
    Corporate_Takeover.PlaceDesk(builder)
end)

function Corporate_Takeover:DrawScrollbar(bar)
	local sbar = bar:GetVBar()

	function sbar:Paint(w, h) end

	function sbar.btnUp:Paint(w, h) end
	sbar.btnDown.Paint = sbar.btnUp.Paint

	function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Corporate_Takeover.Config.Colors.BrightBackground)
		draw.RoundedBox(0, 2, 2, w-4, h-4, Corporate_Takeover.Config.Colors.Primary)
	end
end

function Corporate_Takeover:PrecacheModels(tbl)
    for k, v in ipairs(tbl) do
        util.PrecacheModel(v)
    end
end
Corporate_Takeover:PrecacheModels(Corporate_Takeover.Config.FemaleWorkerModels)
Corporate_Takeover:PrecacheModels(Corporate_Takeover.Config.MaleWorkerModels)