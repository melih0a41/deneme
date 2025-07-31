aphone.Call = aphone.Call or {}

local function init_call(param)
    aphone.Call.Infos = param

    timer.Create("aphone_DringSound", 5, 0, function()
        local info = aphone.Call.Infos
        local firstCheck = IsValid(LocalPlayer()) and LocalPlayer():HasWeapon("aphone") and info and info.pending and not info.is_caller and !aphone:GetParameters("Core", "SilentMode", false)

        if firstCheck and (IsValid(aphone.Call.Infos.target) or info.special_id) then
            aphone.playringtone()
        else
            timer.Remove("aphone_DringSound")
        end
    end)

    if IsValid(aphone.MainDerma) then
        if IsValid(aphone.Call.Panel) then
            aphone.Call.Panel:Remove()
        end

        local call = vgui.Create("aphone_Call", aphone.MainDerma)
        call:SetZPos(3)

        if !param.pending then
            call:Accepted()
        end
    end
end

net.Receive("aphone_Phone", function()
    local id = net.ReadUInt(4)
    local local_player = LocalPlayer()

    if id == 1 then
        -- Asking call
        local ent1 = net.ReadEntity()
        local ent2 = net.ReadEntity()
        local force_accept = net.ReadBool()

        init_call({
            target = (ent1 == local_player and ent2 or ent1),
            is_caller = (ent1 == local_player),
            target_facetime = false,
            facetime = false,
            start_time = os.time(),
            pending = !force_accept
        })

    elseif id == 2 then
        -- Accept call
        aphone.Call.Infos.pending = false

        if aphone.Call.Panel and IsValid(aphone.Call.Panel) then
            aphone.Call.Panel:Accepted()
        end
    elseif id == 3 then
        -- Can't make the call
        aphone.AddNotif("alert", aphone.L("Already_Call"), 3)
    elseif id == 4 then
        -- Facetime enable
        aphone.Call.Infos.target_facetime = !aphone.Call.Infos.target_facetime
    elseif id == 5 then
        -- End of the call
        if aphone.Call.Infos and IsValid(aphone.Call.Infos.target) then
            local i = aphone.Call.Infos
            local t = os.time() - i.start_time
            local settings = aphone.Clientside.GetSetting("callhistory", {})

            if table.Count(settings) >= 50 then
                settings[50] = nil
            end

            local tbl = {
                time = t,
                p = i.pending,
                is_caller = is_caller,
                targetID = i.target:aphone_GetID()
            }

            if !i.is_caller and tbl.p then
                aphone.Clientside.SaveSetting("callmissed",
                    aphone.Clientside.GetSetting("callmissed", 0) + 1)
            end

            table.insert(settings, 1, tbl)

            aphone.Clientside.SaveSetting("callhistory", settings)
        end
        aphone.Call.Infos = nil
    elseif id == 6 then
        -- Special Call
        local num = net.ReadUInt(8)
        local is_caller = net.ReadBool()

        init_call({
            target_facetime = false,
            facetime = false,
            start_time = os.time(),
            pending = true,
            special_id = num,
            is_caller = is_caller,
        })
    end
end)