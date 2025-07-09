/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.Trashbag = ztm.Trashbag or {}
ztm.Trashbag.List = ztm.Trashbag.List or {}

function ztm.Trashbag.Initialize(Trashbag)
    zclib.EntityTracker.Add(Trashbag)
    table.insert(ztm.Trashbag.List ,Trashbag)
end

function ztm.Trashbag.Touch(Trashbag, other)
    if not IsValid(Trashbag) then return end
    if Trashbag:GetTrash() >= ztm.config.Trashbags.capacity then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "ztm_trash" and other:GetClass() ~= "ztm_trashbag" then return end
    if zclib.util.CollisionCooldown(other) then return end
	if zclib.util.CollisionCooldown(Trashbag) then return end

    if other:GetTrash() <= 0 then return end
	if zclib.Entity.GettingRemoved(other) then return end

    ztm.Trashbag.AddTrash(Trashbag, other)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

function ztm.Trashbag.OnTakeDamage(Trashbag, dmginfo)
    if (not Trashbag.ztm_bApplyingDamage) then
        Trashbag.ztm_bApplyingDamage = true
        Trashbag:TakePhysicsDamage(dmginfo)
        local damage = dmginfo:GetDamage()
        local entHealth = ztm.config.Damageable[Trashbag:GetClass()]

        if (entHealth > 0) then
            Trashbag.CurrentHealth = (Trashbag.CurrentHealth or entHealth) - damage
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

            if (Trashbag.CurrentHealth <= 0) then
                zclib.Entity.SafeRemove(Trashbag)
            end
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

        Trashbag.ztm_bApplyingDamage = false
    end
end

function ztm.Trashbag.AddTrash(Trashbag, OtherTrashbag)

	// Only transfer the amount we want to move
	local FreeSpace = ztm.config.Trashbags.capacity - Trashbag:GetTrash()
	if FreeSpace <= 0 then return end

	local moveAmount = math.Clamp(OtherTrashbag:GetTrash(),0,FreeSpace)

    Trashbag:SetTrash(Trashbag:GetTrash() + moveAmount)
	OtherTrashbag:SetTrash(OtherTrashbag:GetTrash() - moveAmount)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

	if OtherTrashbag:GetTrash() <= 0 then
		zclib.Entity.SafeRemove(OtherTrashbag)
	end
end

function ztm.Trashbag.GetCountByPlayer(ply)
    local count = 0

    for k, v in pairs(ztm.Trashbag.List) do
        if IsValid(v) and zclib.Player.IsOwner(ply, v) then
            count = count + 1
        end
    end

    return count
end

function ztm.Trashbag.Create(pos, trash, ply)
    local ent = ents.Create("ztm_trashbag")
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    ent:SetTrash(trash)
    zclib.Player.SetOwner(ent, ply)
end
