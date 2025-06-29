/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.Crate = zvm.Crate or {}

function zvm.Crate.Initialize(Crate)
	zclib.Debug("Crate_Initialize")
	zclib.EntityTracker.Add(Crate)
	Crate.Content = {}
	Crate.IsOpening = false
	Crate.NextInteraction = -1
	Crate.Wait = true
	Crate:SetProgress(5)
	timer.Simple(1, function()
		if IsValid(Crate) then
			Crate.Wait = false
		end
	end)

	if zvm.config.Package.DespawnTime then
		SafeRemoveEntityDelayed(Crate,zvm.config.Package.DespawnTime)
	end
end

function zvm.Crate.USE(Crate, ply)
	if not IsValid(Crate) then return end
	if Crate.Wait then return end
	if not IsValid(ply) then return end
	if Crate.IsOpening then return end

	if zvm.config.Package.BuyerOnlyOpen and zclib.Player.IsOwner(ply, Crate) == false then
		zclib.Notify(ply, zvm.language.General["YouDontOwnThis"], 1)
		return
	end

	if Crate:GetProgress() <= 0 then
		zvm.Crate.Unpack(Crate,ply)
	else
		if CurTime() < Crate.NextInteraction then return end
		Crate.NextInteraction = CurTime() + 0.1
		Crate:SetProgress( Crate:GetProgress() - 1)
	end
end

function zvm.Crate.DirectPickup(itemclass)
	local allowed_item = false

	if zvm.config.Package.DirectPickup.allowed and table.Count(zvm.config.Package.DirectPickup.allowed) > 0 then
		for _, allowed in pairs(zvm.config.Package.DirectPickup.allowed) do
			if (itemclass:find(allowed)) then
				allowed_item = true
			end
		end

		for _, banned in pairs(zvm.config.Package.DirectPickup.banned) do
			if (itemclass:find(banned)) then
				allowed_item = false
			end
		end
	end

	return allowed_item
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function zvm.Crate.Unpack(Crate,ply)

	if table.Count(Crate.Content) <= 0 then return end
	zclib.Notify(ply, zvm.language.General["PackageOpens"] .. "..", 0)

	Crate.IsOpening = true

	// Custom Hook
	hook.Run("zvm_OnPackageOpend" ,ply, Crate)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

	timer.Simple(1,function()
		if IsValid(Crate) then

			Crate:EmitSound("zvm_box_unpack")
			for k, v in pairs(Crate.Content) do

				local UnpackOverwrite = zvm.Module.ItemUnpackOverwrite(v.class, v, ply, Crate)
				if UnpackOverwrite == nil then

					// If this option exist then the player should get the item instantly (Only works for weapons)
					if v.insta_pickup then
						ply:Give(v.class,false)
						continue
					end

					local ent

					// For some entities its better not to use the entity table data (TFA for examble)
					local SkipEntityTableOnSpawn = hook.Run("zvm_SkipEntityTableOnSpawn",v)

					// Try the new method by using the entity table data if available
					if SkipEntityTableOnSpawn and v.entdata then
						ent = duplicator.CreateEntityFromTable(ply,v.entdata)
					end

					// If it was not available or the entity from it was invalid then try the new method
					if not IsValid(ent) then
						ent = ents.Create(v.class)
					end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

					if not IsValid(ent) then continue end
					ent:SetModel(v.model)
					ent:SetPos(Crate:GetPos() + zclib.util.GetRandomPositionInsideCircle(60,100,25))

					// Apply any of the extra data before you spawn it
					zvm.Module.OnItemDataApplyPreSpawn(v.class, ent, v.extraData)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

					ent:Spawn()
					ent:Activate()

					// Assign the owner
					zclib.Player.SetOwner(ent, ply)

					// Apply any of the extra data after you spawned it
					zvm.Module.OnItemDataApply(v.class, ent, v.extraData)

					// Call Special hook so we can call some custom code for each entity
					zvm.Module.OnPackageItemSpawned(v.class, ent, v.extraData, ply)

					local class = (v.class == "spawned_weapon" and (v["extraData"] and (v["extraData"].WeaponClass or v.class) or v.class) or v.class)

					if zvm.Crate.DirectPickup(class) then
						ent:Use(ply ,ply, USE_SET, 1)

						zclib.Notify(ply, "+ " .. v.name, 0)
					end
				end
			end
			SafeRemoveEntity(Crate)
		end
	end)
end

function zvm.Crate.OnRemove(Crate)
	local ply = zclib.Player.GetOwner(Crate)

	if IsValid(ply) then
		zvm.Player.RemovePackage(ply, Crate)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978
