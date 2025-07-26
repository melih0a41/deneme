local category = "Corporate Takeover"

-- Add XP to a corporation
function ulx.setcorp_level(calling_ply, target_ply, amount)
    if not target_ply.CTOHasCorp or not target_ply.CTOCorpID then
        ULib.tsayError(calling_ply, target_ply:Nick() .. " is not part of a corporation!", true)
        return
    end

    local CorpID = target_ply.CTOCorpID
    local Corp = Corporate_Takeover.Corps[CorpID]
    if not Corp then
        ULib.tsayError(calling_ply, "Corporation not found!", true)
        return
    end

    Corporate_Takeover.Corps[CorpID].level = math.Clamp(amount, 0, Corporate_Takeover.Config.MaxCorpLevel)
    Corporate_Takeover:SyncCorp(CorpID)

    ulx.fancyLogAdmin(calling_ply, "#A Set the level of #s to #s", Corp.name, amount)
end
local setcorp_level = ulx.command(category, "ulx setcorplevel", ulx.setcorp_level, "!setcorplevel")
setcorp_level:addParam{type = ULib.cmds.PlayerArg}
setcorp_level:addParam{type = ULib.cmds.NumArg, hint = "Amount"}
setcorp_level:defaultAccess(ULib.ACCESS_ADMIN)
setcorp_level:help("Add XP to a corporation for a player.")

-- Deposit money
function ulx.add_money(calling_ply, target_ply, amount)
    amount = math.floor(amount) -- Ensure amount is an integer
    local formatted = DarkRP.formatMoney(amount)

    if not target_ply.CTOHasCorp or not target_ply.CTOCorpID then
        ULib.tsayError(calling_ply, target_ply:Nick() .. " is not part of a corporation!", true)
        return
    end

    local CorpID = target_ply.CTOCorpID
    local Corp = Corporate_Takeover.Corps[CorpID]
    if not Corp then
        ULib.tsayError(calling_ply, "Corporation not found!", true)
        return
    end

    Corporate_Takeover:AddMoney(CorpID, amount)
    Corporate_Takeover:SyncCorp(CorpID)
    ulx.fancyLogAdmin(calling_ply, "#A added #s to the corporation #s", formatted, Corp.name)
end

local add_money = ulx.command(category, "ulx addcorpmoney", ulx.add_money, "!addcorpmoney")
add_money:addParam{type = ULib.cmds.PlayerArg}
add_money:addParam{type = ULib.cmds.NumArg, hint = "Amount"}
add_money:defaultAccess(ULib.ACCESS_ADMIN)
add_money:help("Deposit money into a player's corporation.")

-- Withdraw money
function ulx.remove_money(calling_ply, target_ply, amount)
    if not target_ply.CTOHasCorp or not target_ply.CTOCorpID then
        ULib.tsayError(calling_ply, target_ply:Nick() .. " is not part of a corporation!", true)
        return
    end

    local CorpID = target_ply.CTOCorpID
    local Corp = Corporate_Takeover.Corps[CorpID]
    if not Corp then
        ULib.tsayError(calling_ply, "Corporation not found!", true)
        return
    end

    Corporate_Takeover:WithdrawMoney(target_ply, amount, true)
    Corporate_Takeover:SyncCorp(CorpID)
    ulx.fancyLogAdmin(calling_ply, "#A removed #s from the corporation #s", DarkRP.formatMoney(amount), Corp.name)
end
local remove_money = ulx.command(category, "ulx takecorpmoney", ulx.remove_money, "!takecorpmoney")
remove_money:addParam{type = ULib.cmds.PlayerArg}
remove_money:addParam{type = ULib.cmds.NumArg, hint = "Amount"}
remove_money:defaultAccess(ULib.ACCESS_ADMIN)
remove_money:help("Withdraw money from a player's corporation.")