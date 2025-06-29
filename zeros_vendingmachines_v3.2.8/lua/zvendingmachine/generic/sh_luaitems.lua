/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

zvm = zvm or {}
zvm.LuaItem = zvm.LuaItem or {}

if SERVER then
	concommand.Add("zvm_luaitem_add", function(ply, cmd, args)
		if IsValid(ply) then
			local class = args[ 1 ]
			if class == nil then return end
			zvm.LuaItem.Add(ply, class)
		end
	end)

	function zvm.LuaItem.Add(ply, class)

	    if zclib.Player.IsAdmin(ply) == false then
	        return
	    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

		local tr = ply:GetEyeTrace()
		if not tr.Hit then return end
		if not IsValid(tr.Entity) then return end
		if tr.Entity:GetClass() ~= "zvm_machine" then return end

        local Machine = tr.Entity
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        if Machine:GetPublicMachine() == false then return end
        if zvm.Machine.ReachedItemLimit(Machine) then return end
        if Machine:GetAllowCollisionInput() == false then return end

		local data = zvm.config.LuaItems[ class ]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

        if not data then
            zclib.Notify(ply, "Lua item could not be found!", 1)
            return
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

        table.insert(Machine.Products,{
            class = "luaitem",
            name = data.name,
            price = 500,
            model = class,
            extraData = {},
            amount = 1,
        })

        // Updates the machine interface for the user which is editing it
        zvm.Machine.UpdateMachineData(Machine,ply)
	end
end

hook.Add("zvm_Overwrite_ProductImage", "zvm_Overwrite_ProductImage_LuaItem", function(pnl, ItemData)
	if ItemData.class == "luaitem" and IsValid(pnl) then

		local data = zvm.config.LuaItems[ ItemData.model ]
		if data then
			pnl.Paint = function(s,w,h)
				surface.SetDrawColor(data.color or color_white)
				surface.SetMaterial(data.icon)
				surface.DrawTexturedRect(0, 0, w, h)
			end
		end

		return true
	end
end)

hook.Add("zvm_Overwrite_IdleImage", "zvm_Overwrite_IdleImage_LuaItem", function(pnl, ItemData)
	if ItemData.class == "luaitem" and IsValid(pnl) then

		local data = zvm.config.LuaItems[ ItemData.model ]
		if data then
			pnl.Paint = function(s,w,h)
				surface.SetDrawColor(data.color or color_white)
				surface.SetMaterial(data.icon)
				surface.DrawTexturedRect(0, 0, w, h)
			end
		end

		return true
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

hook.Add("zvm_Overwrite_ItemUnpack", "zvm_Overwrite_ItemUnpack_LuaItem", function(ply, crate, ItemData)
	if ItemData.class == "luaitem" then
		if IsValid(ply) then
			local data = zvm.config.LuaItems[ ItemData.model ]

			if data then
				pcall(data.lua, ply)
			end
		end

		return true
	end
end)
