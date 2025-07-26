local category = "Corporate Takeover"

-- Add XP to a corporation
sam.command.set_category(category)
sam.command.new("setcorplevel")
    :SetPermission("setcorplevel", "admin")
    :AddArg("player", {hint = "Target Player"})
    :AddArg("number", {hint = "Amount"})
    :Help("Set the level of a player's corporation.")
    :OnExecute(function(calling_ply, targets, amount)
        local target_ply = targets[1]
        if not target_ply.CTOHasCorp or not target_ply.CTOCorpID then
            sam.player.send_message(calling_ply, "{T} is not part of a corporation!", {T = target_ply})
            return
        end

        local CorpID = target_ply.CTOCorpID
        local Corp = Corporate_Takeover.Corps[CorpID]
        if not Corp then
            sam.player.send_message(calling_ply, "Corporation not found!")
            return
        end

        amount = math.Clamp(amount, 0, Corporate_Takeover.Config.MaxCorpLevel)

        Corporate_Takeover.Corps[CorpID].level = amount
        Corporate_Takeover:SyncCorp(CorpID)

        sam.player.send_message(nil, "{A} set the level of {T} to {V}", {
            A = calling_ply, T = Corp.name, V = amount
        })
    end)
:End()

-- Deposit money
sam.command.new("addcorpmoney")
    :SetPermission("addcorpmoney", "admin")
    :AddArg("player", {hint = "Target Player"})
    :AddArg("number", {hint = "Amount"})
    :Help("Deposit money into a player's corporation.")
    :OnExecute(function(calling_ply, targets, amount)
        local target_ply = targets[1]
        amount = math.floor(amount) -- Ensure amount is an integer
        local formatted = DarkRP.formatMoney(amount)

        if not target_ply.CTOHasCorp or not target_ply.CTOCorpID then
            sam.player.send_message(calling_ply, "{T} is not part of a corporation!", {T = target_ply})
            return
        end

        local CorpID = target_ply.CTOCorpID
        local Corp = Corporate_Takeover.Corps[CorpID]
        if not Corp then
            sam.player.send_message(calling_ply, "Corporation not found!")
            return
        end

        Corporate_Takeover:AddMoney(CorpID, amount)
        Corporate_Takeover:SyncCorp(CorpID)
        sam.player.send_message(nil, "{A} added {T} to the corporation {V}", {
            A = calling_ply, T = formatted, V = Corp.name
        })
    end)
:End()

-- Withdraw money
sam.command.new("takecorpmoney")
    :SetPermission("takecorpmoney", "admin")
    :AddArg("player", {hint = "Target Player"})
    :AddArg("number", {hint = "Amount"})
    :Help("Withdraw money from a player's corporation.")
    :OnExecute(function(calling_ply, targets, amount)
        local target_ply = targets[1]
        if not target_ply.CTOHasCorp or not target_ply.CTOCorpID then
            sam.player.send_message(calling_ply, "{T} is not part of a corporation!", {T = target_ply})
            return
        end

        local CorpID = target_ply.CTOCorpID
        local Corp = Corporate_Takeover.Corps[CorpID]
        if not Corp then
            sam.player.send_message(calling_ply, "Corporation not found!")
            return
        end

        Corporate_Takeover:WithdrawMoney(target_ply, amount, true)
        Corporate_Takeover:SyncCorp(CorpID)
        sam.player.send_message(nil, "{A} removed {T} from the corporation {V}", {
            A = calling_ply, T = DarkRP.formatMoney(amount), V = Corp.name
        })
    end)
:End()