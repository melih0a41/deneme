/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.Buyermachine = ztm.Buyermachine or {}

ztm.Buyermachine.List = ztm.Buyermachine.List or {}

function ztm.Buyermachine.Initialize(Buyermachine)
    zclib.EntityTracker.Add(Buyermachine)

    Buyermachine.PayoutMode = false
    Buyermachine.Wait = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

    table.insert(ztm.Buyermachine.List,Buyermachine)
end

function ztm.Buyermachine.Touch(Buyermachine, other)
    if Buyermachine.Wait == true then return end
    if Buyermachine:GetIsInserting() then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "ztm_recycled_block" then return end
    if zclib.util.CollisionCooldown(other) then return end
    if IsValid(Buyermachine:GetMoneyEnt()) then return end

    ztm.Buyermachine.AddBlock(Buyermachine, other)
end

function ztm.Buyermachine.AddBlock(Buyermachine, block)
    Buyermachine:SetIsInserting(true)

    local block_value = ztm.config.Recycler.recycle_types[block:GetRecycleType()].money

    Buyermachine:SetBlockType(block:GetRecycleType())

    Buyermachine:SetMoney(Buyermachine:GetMoney() + block_value)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

    SafeRemoveEntity(block)

    timer.Simple(1.7,function()
        if IsValid(Buyermachine) then
            Buyermachine:SetIsInserting(false)
        end
    end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ztm.Buyermachine.USE(Buyermachine,ply)
    if Buyermachine.Wait == true then return end
    if Buyermachine:GetIsInserting() then return end
    if IsValid(Buyermachine:GetMoneyEnt()) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

    if Buyermachine:OnPayoutButton(ply) then

        local cash = Buyermachine:GetMoney()
        if cash <= 0 then return end

        local modify = (1 / 100) * Buyermachine:GetPriceModify()
        cash = cash * modify

		cash = cash * ztm.Player.GetTrashSellMultiplicator(ply)

        Buyermachine:EmitSound("ztm_ui_click")

        // Custom Hook
        hook.Run("ztm_OnTrashBlockSold" ,ply, Buyermachine, cash)


        // Spawn money
        local pos = Buyermachine:GetPos() +  Buyermachine:GetUp() * 61.8 + Buyermachine:GetRight() * -17 + Buyermachine:GetForward() * -11.7
        local money = ztm.config.MoneySpawn(pos,cash,ply)
		if IsValid(money) then
	        local ang = Buyermachine:GetAngles()
	        ang:RotateAroundAxis(Buyermachine:GetUp(),90)
	        money:SetAngles(ang)
	        money:SetParent(Buyermachine)

	        // In this time only the customer can pickup the money
	        money.ztm_Owner = ply
	        money.ztm_SafeTime = CurTime() + 15

	        Buyermachine:SetMoneyEnt(money)
		else
			Buyermachine:SetMoneyEnt(NULL)
		end
		Buyermachine:SetMoney(0)
        Buyermachine.PayoutMode = true
        Buyermachine.Wait = true
    end
end

function ztm.Buyermachine.Think(Buyermachine)
    if Buyermachine.PayoutMode == true and not IsValid(Buyermachine:GetMoneyEnt()) then
        Buyermachine.PayoutMode = false

        timer.Simple(1, function()
            if IsValid(Buyermachine) then
                Buyermachine.Wait = false
            end
        end)
    end
end

///////////////////////////////////////////
// Block use interaction a few seconds so the player can take the money
zclib.Hook.Add("PlayerUse", "ztm_buyermachine", function(ply, ent)
    if IsValid(ent) and IsValid(ply) and ent:GetClass() == "spawned_money" and ent.ztm_SafeTime and CurTime() < ent.ztm_SafeTime and ply ~= ent.ztm_Owner then
        return false
    end
end)


///////////////////////////////////////////
// Dynamic BuyRate
timer.Simple(0,function()
    zclib.Timer.Remove("ztm_buyermarkt_id")

    if ztm.config.Buyermachine.DynamicBuyRate then
        zclib.Timer.Create("ztm_buyermarkt_id",ztm.config.Buyermachine.RefreshRate, 0, ztm.Buyermachine.ChangeMarkt)
    end
end)

function ztm.Buyermachine.RefreshBuyRate(Buyermachine)
    local newProfit = math.random(ztm.config.Buyermachine.MinBuyRate, ztm.config.Buyermachine.MaxBuyRate)
    zclib.Debug("ztm.Buyermachine.RefreshBuyRate: " .. newProfit .. "%")
    Buyermachine:SetPriceModify(newProfit)
end

function ztm.Buyermachine.ChangeMarkt()
    for k, v in pairs(ztm.Buyermachine.List) do
        if IsValid(v) then
            ztm.Buyermachine.RefreshBuyRate(v)
        end
    end
end

///////////////////////////////////////////
file.CreateDir("ztm")

concommand.Add("ztm_buyermachine_save", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Buyermachine entities have been saved for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Save("ztm_buyermachine")
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

concommand.Add("ztm_buyermachine_remove", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Buyermachine entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Remove("ztm_buyermachine")
    end
end)

zclib.STM.Setup("ztm_buyermachine", "ztm/" .. string.lower(game.GetMap()) .. "_buyermachines.txt", function()
    local data = {}

    for u, j in pairs(ztm.Buyermachine.List) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end

    return data
end, function(data)
    for k, v in pairs(data) do
        local ent = ents.Create("ztm_buyermachine")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()
        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end

    ztm.Print("Finished loading Buyermachine Entities.")
end, function()
    for k, v in pairs(ztm.Buyermachine.List) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)
