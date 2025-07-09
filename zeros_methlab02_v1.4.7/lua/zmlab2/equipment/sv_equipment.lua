/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.Equipment = zmlab2.Equipment or {}

function zmlab2.Equipment.Initialize(Equipment)
    zclib.EntityTracker.Add(Equipment)

	Equipment:SetMaxHealth( zmlab2.config.Damageable[Equipment:GetClass()] )
	Equipment:SetHealth(Equipment:GetMaxHealth())
end

function zmlab2.Equipment.OnRemove(Equipment)

end

function zmlab2.Equipment.OnUse(Equipment, ply)

    if zmlab2.Player.CanInteract(ply, Equipment) == false then return end

    if Equipment:OnRepair(ply) then
        net.Start("zmlab2_Equipment_Repair")
        net.WriteEntity(Equipment)
        net.Send(ply)
    end

    if zmlab2.config.Equipment.RepairOnly == true then return end

    if Equipment:OnBuild(ply) then
        zmlab2.Equipment.OpenInterface(Equipment, ply)
    elseif Equipment:OnMove(ply) then
        net.Start("zmlab2_Equipment_Move")
        net.WriteEntity(Equipment)
        net.Send(ply)
    elseif Equipment:OnRemoveButton(ply) then
        net.Start("zmlab2_Equipment_Deconstruct")
        net.WriteEntity(Equipment)
        net.Send(ply)
    end
end

util.AddNetworkString("zmlab2_Equipment_OpenInterface")
function zmlab2.Equipment.OpenInterface(Equipment,ply)
    net.Start("zmlab2_Equipment_OpenInterface")
    net.WriteEntity(Equipment)
    net.Send(ply)
end

util.AddNetworkString("zmlab2_Equipment_Place")
net.Receive("zmlab2_Equipment_Place", function(len,ply)
    zclib.Debug_Net("zmlab2_Equipment_Place",len)
    if zclib.Player.Timeout(nil,ply) == true then return end

    local Equipment = net.ReadEntity()
    local Tent = net.ReadEntity()
    local AttachID = net.ReadInt(16)
    local BuildPos = net.ReadVector()
    local BuildAng = net.ReadAngle()
    local EquipmentID = net.ReadUInt(16)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

    if zmlab2.config.Equipment.RepairOnly == true then return end

    if not IsValid(Equipment) then return end

    if zmlab2.config.Equipment.RestrictToTent == true and not IsValid(Tent) then return end

    // Run a distance check on EquipmentBox and BuildPos
    if zclib.util.InDistance(ply:GetPos(), Equipment:GetPos(), 1000) == false then return end
    if BuildPos and zclib.util.InDistance(ply:GetPos(), BuildPos, 1000) == false then return end

    if zmlab2.Player.CanInteract(ply, Equipment) == false then return end
    if IsValid(Tent) and zmlab2.Player.CanInteract(ply, Tent) == false then return end

    zmlab2.Equipment.Place(Equipment,Tent,ply,AttachID,EquipmentID,BuildPos,BuildAng)
end)
function zmlab2.Equipment.LimitCheck(ply,ItemID)
    local EquipmentData = zmlab2.config.Equipment.List[ItemID]
    local class = EquipmentData.class
    local limit = hook.Run("zmlab2_Equipment_GetItemLimit",ply,ItemID) or EquipmentData.limit

    local count = 0
    for k, v in pairs(zclib.EntityTracker.GetList()) do
        if IsValid(v) and v:GetClass() == class and zclib.Player.IsOwner(ply, v) then
            count = count + 1
        end
    end

    if count >= limit then
        return false
    else
        return true
    end
end
function zmlab2.Equipment.Place(Equipment,Tent,ply,AttachID,EquipmentID,BuildPos,BuildAng)
    if AttachID == nil then return end
    if BuildPos == nil then return end
    if BuildAng == nil then return end

    // First attach is for UI so ignore that
    if AttachID == 1 then return end

    local EquipmentData = zmlab2.config.Equipment.List[EquipmentID]
    if EquipmentData == nil then return end

    // Can the player build any more of this machine?
    if zmlab2.Equipment.LimitCheck(ply,EquipmentID) == false then
        local str = zmlab2.language["ItemLimit"]
        str = string.Replace(str,"$ItemName",EquipmentData.name)
        zclib.Notify(ply, str, 1)
        return
    end

    // Where are we bulding?
    local pos,ang
    if zmlab2.config.Equipment.RestrictToTent == true then
        local Attach = Tent:GetAttachment(AttachID)
        if Attach == nil then return end
        pos = Attach.Pos
        ang = Attach.Ang
    else
        pos = BuildPos
        ang = BuildAng
    end
    if pos == nil or ang == nil then return end
	// 288688181
    // Is some player in the way?
    if zmlab2.Equipment.AreaOccupied(pos) then return end

    if zclib.Money.Has(ply, EquipmentData.price) == false then
        zclib.Notify(ply, zmlab2.language["NotEnoughMoney"], 1)

        return
    end

    local ent = ents.Create(EquipmentData.class)
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:Activate()

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end

    //debugoverlay.Sphere(ent:GetPos(),15,5,Color( 255, 125, 0 ),true)



    // Here we create a connection between those two entities so they know each other
    if ent.Tent then
		if ent.Tent.ConnectedEnts == nil then ent.Tent.ConnectedEnts = {} end
		ent.Tent.ConnectedEnts[ent] = nil
	end
    if IsValid(Tent) then
        ent.Tent = Tent
		if Tent.ConnectedEnts == nil then Tent.ConnectedEnts = {} end
        Tent.ConnectedEnts[ent] = true
    end

    ent.PhysgunDisabled = zmlab2.config.Equipment.PhysgunDisabled

    zclib.Gamemode.SimulateBuy(ply,ent,EquipmentData.name,EquipmentData.price)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    zclib.Money.Take(ply, EquipmentData.price)
    zclib.Notify(ply, "-" .. zclib.Money.Display(math.Round(EquipmentData.price)), 0)

    zclib.Player.SetOwner(ent, ply)
    zclib.Sound.EmitFromEntity("cash", ent)
end


util.AddNetworkString("zmlab2_Equipment_Deconstruct")
net.Receive("zmlab2_Equipment_Deconstruct", function(len,ply)
    zclib.Debug_Net("zmlab2_Equipment_Deconstruct",len)
    if zclib.Player.Timeout(nil,ply) == true then return end

    local Machine = net.ReadEntity()

    if zmlab2.config.Equipment.RepairOnly == true then return end

    if not IsValid(Machine) then return end
    if zmlab2.Equipment_Classes[Machine:GetClass()] == nil then return end

    if zmlab2.Player.CanInteract(ply, Machine) == false then return end

    if zclib.Player.IsAdmin(ply) == false and zmlab2.Player.CanInteract(ply, Machine) == false then return end

    if zmlab2.config.Equipment.Refund > 0 then
        local refund_money = zmlab2.config.Equipment.List[zmlab2.Equipment_Classes[Machine:GetClass()]].price * zmlab2.config.Equipment.Refund
        if refund_money > 0 then

            zclib.Sound.EmitFromPosition(Machine:GetPos(),"cash")

            // Give the player the Cash
            zclib.Money.Give(ply, refund_money)

            // Notify the player
            zclib.Notify(ply, "+" .. zclib.Money.Display(math.Round(refund_money)), 0)
        end
    end

    SafeRemoveEntity(Machine)
end)


util.AddNetworkString("zmlab2_Equipment_Move")
net.Receive("zmlab2_Equipment_Move", function(len,ply)
    zclib.Debug_Net("zmlab2_Equipment_Move",len)
    if zclib.Player.Timeout(nil,ply) == true then return end

    local Machine = net.ReadEntity()
    local Tent = net.ReadEntity()
    local AttachID = net.ReadInt(16)
    local BuildPos = net.ReadVector()
    local BuildAng = net.ReadAngle()

    if zmlab2.config.Equipment.RepairOnly == true then return end

    if not IsValid(Machine) then return end
    if zmlab2.config.Equipment.RestrictToTent == true and not IsValid(Tent) then return end

    // Run a distance check on EquipmentBox and BuildPos
    if zclib.util.InDistance(ply:GetPos(), Machine:GetPos(), 1000) == false then return end
    if BuildPos and zclib.util.InDistance(ply:GetPos(), BuildPos, 1000) == false then return end

    if zmlab2.Player.CanInteract(ply, Machine) == false then return end
    if IsValid(Tent) and zmlab2.Player.CanInteract(ply, Tent) == false then return end

    zmlab2.Equipment.Move(Machine,Tent,ply,AttachID,BuildPos,BuildAng)
end)
function zmlab2.Equipment.Move(Machine,Tent,ply,AttachID,BuildPos,BuildAng)
    if AttachID == nil then return end
    if BuildPos == nil then return end
    if BuildAng == nil then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

    // First attach is for UI so ignore that
    if AttachID == 1 then return end

    // Where are we bulding?
    local pos,ang
    if zmlab2.config.Equipment.RestrictToTent == true then
        local Attach = Tent:GetAttachment(AttachID)
        if Attach == nil then return end
        pos = Attach.Pos
        ang = Attach.Ang
    else
        pos = BuildPos
        ang = BuildAng
    end
    if pos == nil or ang == nil then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

    // Is some player in the way?
    if zmlab2.Equipment.AreaOccupied(pos,Machine) then return end

    if zmlab2.Equipment_Classes[Machine:GetClass()] == nil then return end

    if zclib.Player.IsAdmin(ply) == false and zmlab2.Player.CanInteract(ply, Machine) == false then return end

    Machine:SetPos(pos)
    Machine:SetAngles(ang)

    Machine.PhysgunDisabled = zmlab2.config.Equipment.PhysgunDisabled

    // Here we create a connection between those two entities so they know each other
    if Machine.Tent then
		if Machine.Tent.ConnectedEnts == nil then Machine.Tent.ConnectedEnts = {} end
		Machine.Tent.ConnectedEnts[Machine] = nil
	end

    if IsValid(Tent) then
        Machine.Tent = Tent
		if Tent.ConnectedEnts == nil then Tent.ConnectedEnts = {} end
        Tent.ConnectedEnts[Machine] = true
    end

    zclib.Sound.EmitFromEntity("tray_drop", Machine)
end


util.AddNetworkString("zmlab2_Equipment_Repair")
net.Receive("zmlab2_Equipment_Repair", function(len,ply)
    zclib.Debug_Net("zmlab2_Equipment_Repair",len)
    if zclib.Player.Timeout(nil,ply) == true then return end

    local Machine = net.ReadEntity()
    if not IsValid(Machine) then return end

    if zclib.Player.IsAdmin(ply) == false and zmlab2.Player.CanInteract(ply, Machine) == false then return end

    zclib.Sound.EmitFromEntity("cash", Machine)

    zclib.Damage.Repair(Machine)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6
