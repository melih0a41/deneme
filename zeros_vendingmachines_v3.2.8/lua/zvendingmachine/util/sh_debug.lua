/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if SERVER then
	util.AddNetworkString("zvm_debug_machine")

	concommand.Add("zvm_debug_vendingmachine", function(ply, cmd, args)
		if IsValid(ply) and zclib.Player.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

			if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zvm_machine" then
				local ent = tr.Entity
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

				if ent.Products then
					PrintTable(ent.Products)
				end

				net.Start("zvm_debug_machine")
				net.WriteEntity(ent)
				net.Send(ply)
			end
		end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

if CLIENT then
	net.Receive("zvm_debug_machine", function(len, ply)
		zclib.Debug("zvm_debug_machine Netlen: " .. len)
		local ent = net.ReadEntity()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

		if IsValid(ent) then
			print("____________________")
			print(tostring(ent))
			print("BuyCount: " .. ent.BuyCount)
			print("BuyCost: " .. ent.BuyCost)
			print("____________________")

			if ent.Products then
				PrintTable(ent.Products)
			end
		end
	end)
end
