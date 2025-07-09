/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.Tent = zmlab2.Tent or {}

function zmlab2.Tent.Initialize(Tent)
    Tent:PhysicsInit(SOLID_VPHYSICS)
    Tent:SetSolid(SOLID_VPHYSICS)
    Tent:SetMoveType(MOVETYPE_VPHYSICS)
    Tent:SetUseType(SIMPLE_USE)
    Tent:UseClientSideAnimation()
    local phys = Tent:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end

    zclib.EntityTracker.Add(Tent)

    Tent.ConnectedEnts = {
        //[ent] = true,
    }


    Tent:SetMaxHealth( zmlab2.config.Damageable[Tent:GetClass()] )
    Tent:SetHealth(Tent:GetMaxHealth())
end

function zmlab2.Tent.OnRemove(Tent)
    zclib.Timer.Remove("zmlab2_Tent_ConstructionTimer_" .. Tent:EntIndex())
end

function zmlab2.Tent.OnUse(Tent,ply)

    if zmlab2.Player.CanInteract(ply, Tent) == false then return end

    local i_state = Tent:GetBuildState()

    // Is it unfolded
    if i_state < 1 then

        // Opens the interface to select a tent type
        zmlab2.Tent.OpenInterface(Tent,ply,false)
    elseif i_state == 2 then
        // Do we want to change the light?
        if Tent:OnLightButton(ply) then
            zmlab2.Tent.OpenInterface(Tent,ply,false)

        // Do we want to Extinguish something
        elseif Tent:OnExtinquisher(ply) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

            zmlab2.Extinguisher.OnUse(Tent,ply)

        // Do we want to unfold the tent?
        elseif Tent:OnFoldButton(ply) then

            // We dont allow public setups to be sold / unfolded
            if Tent:GetIsPublic() == true then return end

            zmlab2.Tent.OpenInterface(Tent,ply,true)
        end
    end
end

util.AddNetworkString("zmlab2_Tent_OpenInterface")
function zmlab2.Tent.OpenInterface(Tent,ply,fold)
    net.Start("zmlab2_Tent_OpenInterface")
    net.WriteEntity(Tent)
    net.WriteInt(Tent:GetTentID(),16)
    net.WriteBool(fold)
    net.Send(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

util.AddNetworkString("zmlab2_Tent_ChangeType")
net.Receive("zmlab2_Tent_ChangeType", function(len,ply)
    zclib.Debug_Net("zmlab2_Tent_ChangeType",len)
    if zclib.Player.Timeout(nil,ply) == true then return end

    local Tent = net.ReadEntity()
    if not IsValid(Tent) then return end
    if Tent:GetClass() ~= "zmlab2_tent" then return end
    if zclib.util.InDistance(Tent:GetPos(), ply:GetPos(), 2000) == false then return end

    if Tent:GetBuildState() > 0 then return end

    if zmlab2.Player.CanInteract(ply, Tent) == false then return end

    local TentID = net.ReadInt(16)

    if zmlab2.config.Tent[TentID] and zmlab2.config.Tent[TentID].customcheck and zmlab2.config.Tent[TentID].customcheck(ply) == false then return end

    Tent:SetTentID(TentID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

    if TentID > 0 then
        Tent:SetBuildState(0)
    else
        Tent:SetBuildState(-1)
    end

    // Start unfold process
    zclib.Sound.EmitFromEntity("tent_unfold", Tent)
    zclib.Debug("Start unfold process")

    timer.Simple(0.1,function()
        net.Start("zmlab2_Tent_ChangeType")
        net.WriteEntity(Tent)
        net.Broadcast()
    end)
end)

util.AddNetworkString("zmlab2_Tent_Build")
net.Receive("zmlab2_Tent_Build", function(len,ply)
    zclib.Debug_Net("zmlab2_Tent_Build",len)
    if zclib.Player.Timeout(nil,ply) == true then return end


    local Tent = net.ReadEntity()
    if not IsValid(Tent) then return end
    if Tent:GetClass() ~= "zmlab2_tent" then return end
    if zclib.util.InDistance(Tent:GetPos(), ply:GetPos(), 2000) == false then return end
    if zmlab2.Player.CanInteract(ply, Tent) == false then return end

    if Tent:GetTentID() <= 0 then return end

    if Tent:GetBuildState() == 0 then

        local TentData = zmlab2.config.Tent[Tent:GetTentID()]
        if TentData == nil then return end

        if TentData.customcheck and TentData.customcheck(ply) == false then return end

        // Start building process
        Tent:SetBuildState(1)
        Tent:SetBuildCompletion(math.Round(CurTime() + TentData.construction_time))
        zclib.Debug("Start building process")

        // Notify all players to clear the area
        for k,v in pairs(ents.FindInSphere(Tent:GetPos(),500)) do
            if not IsValid(v) then continue end
            if v:IsPlayer() == false then continue end
            zclib.Notify(v, zmlab2.language["TentBuild_Info"], 3)
        end

        local timerid = "zmlab2_Tent_ConstructionTimer_" .. Tent:EntIndex()
        zclib.Timer.Create(timerid, TentData.construction_time, 1, function()
            zmlab2.Tent.CompleteBuilder(Tent,ply)
            zclib.Timer.Remove(timerid)
        end)
    end
end)

util.AddNetworkString("zmlab2_Tent_UpdateLightColorID")
net.Receive("zmlab2_Tent_UpdateLightColorID", function(len,ply)
    zclib.Debug_Net("zmlab2_Tent_UpdateLightColorID",len)
    if zclib.Player.Timeout(nil,ply) == true then return end

    local Tent = net.ReadEntity()
    if not IsValid(Tent) then return end
    if Tent:GetClass() ~= "zmlab2_tent" then return end
    if zclib.util.InDistance(Tent:GetPos(), ply:GetPos(), 2000) == false then return end
    if zmlab2.Player.CanInteract(ply, Tent) == false then return end

    local ColorID = net.ReadUInt(16)

    Tent:SetColorID(ColorID)
end)

function zmlab2.Tent.CompleteBuilder(Tent,ply)
    if not IsValid(Tent) then return end
    if not IsValid(ply) then return end
    if zmlab2.Tent.Builder_HasSpace(Tent) == false or zmlab2.Tent.Builder_IsAreaFree(Tent) == false then
        zclib.Notify(ply, zmlab2.language["TentBuild_Abort"], 1)
        zclib.Debug("zmlab2.Tent.CompleteBuilder [FAILED]")
        Tent:SetBuildState(0)
        return
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    local TentData = zmlab2.config.Tent[Tent:GetTentID()]
    if TentData == nil then
        Tent:SetBuildState(0)
        return
    end

    if zclib.Money.Has(ply, TentData.price) == false then
        zclib.Notify(ply, zmlab2.language["NotEnoughMoney"], 1)
        Tent:SetBuildState(0)
        return
    end
    zclib.Money.Take(ply, TentData.price)
    zclib.Notify(ply, "-" .. zclib.Money.Display(math.Round(TentData.price)), 0)

    zclib.Debug("zmlab2.Tent.CompleteBuilder [SUCESS]")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

    Tent:SetBuildState(2)
    zclib.Sound.EmitFromEntity("tent_construction_complete", Tent)

    zclib.Notify(ply, zmlab2.language["ConstructionCompleted"], 0)


    Tent:SetModel(TentData.model)
    Tent:PhysicsInit(SOLID_VPHYSICS)
    Tent:SetSolid(SOLID_VPHYSICS)
    Tent:SetMoveType(MOVETYPE_NONE)

    local phys = Tent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion( false )
		phys:AddGameFlag( FVPHYSICS_CONSTRAINT_STATIC )
		phys:SetMass(4000)
		phys:EnableDrag(false)
        phys:SetDamping(100, 100)
    end
    Tent:AddEFlags(EFL_NO_PHYSCANNON_INTERACTION)
    Tent:AddEFlags(EFL_NO_DAMAGE_FORCES)

    Tent.PhysgunDisabled = true

    if TentData.color then
        Tent:SetColor(TentData.color)
    end

    // Spawn door
    local attach_door = Tent:GetAttachment(2)
    local door = ents.Create("zmlab2_tent_door")
    if not IsValid(door) then return end
    door:SetPos(attach_door.Pos)
    door:SetAngles(attach_door.Ang)
    door:Spawn()
    door:Activate()
    door:SetParent(Tent)
    Tent.Door = door
    zclib.Player.SetOwner(door, ply)
end


util.AddNetworkString("zmlab2_Tent_Fold")
net.Receive("zmlab2_Tent_Fold", function(len,ply)
    zclib.Debug_Net("zmlab2_Tent_Fold",len)
    if zclib.Player.Timeout(nil,ply) == true then return end

    local Tent = net.ReadEntity()
    if not IsValid(Tent) then return end
    if Tent:GetClass() ~= "zmlab2_tent" then return end
    if zclib.util.InDistance(Tent:GetPos(), ply:GetPos(), 2000) == false then return end
    //if zmlab2.Player.CanInteract(ply, Tent) == false then return end
    if zclib.Player.IsOwner(ply, Tent) == false and zclib.Player.IsAdmin(ply) == false then return end

    zmlab2.Tent.Fold(Tent,ply)
end)

function zmlab2.Tent.Fold(Tent,ply)

    local refund_money = 0
    for k,v in pairs(Tent.ConnectedEnts) do
        if IsValid(k) then
            if zmlab2.config.Equipment.Refund > 0 then
                refund_money = refund_money + zmlab2.config.Equipment.List[zmlab2.Equipment_Classes[k:GetClass()]].price * zmlab2.config.Equipment.Refund
            end
            SafeRemoveEntity(k)
        end
    end

    if refund_money > 0 then
        zclib.Sound.EmitFromPosition(Tent:GetPos(),"cash")

        // Give the player the Cash
        zclib.Money.Give(ply, refund_money)

        // Notify the player
        zclib.Notify(ply, "+" .. zclib.Money.Display(math.Round(refund_money)), 0)
    end

    SafeRemoveEntity(Tent.Door)

    Tent:SetModel("models/zerochain/props_methlab/zmlab2_tentkit.mdl")
    Tent:PhysicsInit(SOLID_VPHYSICS)
    Tent:SetSolid(SOLID_VPHYSICS)
    Tent:SetMoveType(MOVETYPE_VPHYSICS)
    Tent:SetUseType(SIMPLE_USE)
    local phys = Tent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end
    Tent:RemoveEFlags(EFL_NO_PHYSCANNON_INTERACTION)
    Tent:RemoveEFlags(EFL_NO_DAMAGE_FORCES)
    Tent.PhysgunDisabled = false

    Tent:SetTentID(-1)

    // Unfolded
    Tent:SetBuildState(-1)
    Tent:SetBuildCompletion(-1)
end

function zmlab2.Tent.OnTakeDamage(Tent,dmginfo)

end
