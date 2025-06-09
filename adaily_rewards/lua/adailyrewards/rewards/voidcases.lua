local Reward = {}

Reward.Name = "VoidCases"

Reward.MaxAmount = 1

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
    local item = VoidCases.Config.Items[key]
    if !item then return end
    local sid = ply:SteamID64()

    VoidCases.AddItem(sid, key, amount)
    VoidCases.NetworkItem(ply, key, amount)
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 4 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;
--PrintTable(VoidCases.Config.Items)

Reward.DrawFunc = function(key, parent)
	if !VoidCases.Config.Items[key] then return end

	local itemInfo = VoidCases.Config.Items[key]
	local itemRarity = tonumber(itemInfo.info.rarity)

	local mW, mH = parent:GetWide(), parent:GetTall()
	local rPanel = vgui.Create( "DPanel" , parent )
    rPanel:SetPos( mW*0.10+1, mH*0.10 )
	rPanel:SetSize( mW*0.80, mH*0.80 )
    rPanel.Paint = function(self, w, h)
    	--ADRewards.draw_RoundedTextureBox(8, 0, 0, w, h, VoidCases.RarityColors[itemRarity])
    	local rmat = itemRarity != 1 && VoidCases.Icons.LayerItem || VoidCases.Icons.LayerItemNormal
		ADRewards.draw_RoundedTextureBox(8, 0, 0, w, h, VoidCases.RarityColors[itemRarity], rmat)
	end


	if (VoidCases.IsModel(itemInfo.info.icon)) then
		rPanel.icon =  vgui.Create( "DModelPanel" , rPanel )
		rPanel.icon:Dock(FILL)
		local dock = rPanel:GetWide()*0.10
		rPanel.icon:DockMargin(dock,dock,dock,dock)
		rPanel.icon:SetZPos(5)

		rPanel.icon:SetModel(itemInfo.info.icon or "models/voidcases/plastic_crate.mdl")
		if (!IsValid(rPanel.icon.Entity)) then 
			VoidCases.Print("Tried to set model, but model not valid! (" .. itemInfo.info.icon .. ")")
			return
		end
		
		
		local this = rPanel
		function rPanel.icon:LayoutEntity(ent) 
			if (this.b and this.b:IsHovered()) then
				local ang = ent:GetAngles().y + RealFrameTime() * 100
				if (ang > 360) then
					ang = 0
				end
				ent:SetAngles( Angle(0, ang, 0) )
			end
		end

		local mn, mx = rPanel.icon.Entity:GetRenderBounds()
		local size = 0
		size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
		size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
		size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )

		rPanel.icon:SetFOV( itemInfo.info.zoom or 55 )
		rPanel.icon:SetCamPos( Vector( size, size, size ) )
		rPanel.icon:SetLookAt( ( mn + mx ) * 0.5 )

		if (itemInfo.type == VoidCases.ItemTypes.Case) then
			rPanel.icon.Entity:SetAngles(Angle(0, 25, 0))
		end

		-- this fixes the depth issue
		function rPanel.icon:DrawModel()

        	local curparent = self
        	local leftx, topy = self:LocalToScreen( 0, 0 )
			local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
			while ( curparent:GetParent() != nil ) do
				curparent = curparent:GetParent()

				local x1, y1 = curparent:LocalToScreen( 0, 0 )
				local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

				leftx = math.max( leftx, x1 )
				topy = math.max( topy, y1 )
				rightx = math.min( rightx, x2 )
				bottomy = math.min( bottomy, y2 )
				previous = curparent
			end

			-- Causes issues with stencils, but only for some people?
			render.ClearDepth() -- this is uncommented

			render.SetScissorRect( leftx, topy, rightx, bottomy, true )

			local ret = self:PreDrawModel( self.Entity )
			if ( ret != false ) then
				self.Entity:DrawModel()
				self:PostDrawModel( self.Entity )
			end

			render.SetScissorRect( 0, 0, 0, 0, false )

		end
		
		if (itemInfo and itemInfo.info.actionType == "weapon") then
			-- csgo knives skin compatibility
			local wepInfo = weapons.Get(itemInfo.info.actionValue)
			if (wepInfo and wepInfo.SkinIndex and isnumber(wepInfo.SkinIndex)) then
				rPanel.icon.Entity:SetSkin(wepInfo.SkinIndex)
			end
		end

		if (itemInfo and itemInfo.info.caseColor) then
			local c = itemInfo.info.caseColor
			local color = Color(c.r, c.g, c.b)
			
			if (!VoidCases.CachedMaterials[itemInfo.info.caseIcon]) then
				VoidCases.FetchImage(itemInfo.info.caseIcon, function () 
				end)
			end

			rPanel.icon.Entity:SetNWVector("CrateColor", color:ToVector())
			rPanel.icon.Entity:SetNWString("CrateLogo", itemInfo.info.caseIcon)
		end

		if (itemInfo.info.actionType == "weapon_skin") then
			local easySkin = SH_EASYSKINS.GetSkin(itemInfo.info.weaponSkin)
			if (easySkin) then
				SH_EASYSKINS.ApplySkinToModel(rPanel.icon.Entity, easySkin.material.path)
			end
		end
	else
		local placeholderMat = "models/voidcases/plastic_crate/logo"
		rPanel.icon =  vgui.Create( "DImage" , rPanel )
		rPanel.icon:Dock(FILL)
		local dock = rPanel:GetWide()*0.15
		rPanel.icon:DockMargin(dock,dock,dock,dock)
		rPanel.icon:SetZPos(5)

		VoidCases.FetchImage(itemInfo.info.icon, function (res)
			rPanel.icon:SetImage("data/voidcases/"..itemInfo.info.icon..".png" or placeholderMat)
		end)	
	end
	rPanel.icon:SetMouseInputEnabled(false)


    return rPanel
end

Reward.DrawKey = "Unique ID"

Reward.GetKey = function(name)
	local uid = tonumber(name)
	local key = uid and VoidCases.Config.Items[uid] and uid or nil
	return key
end

Reward.LangPhrase = "VoidCases_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use a unique item identifier."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте унікальний ідентифікатор предмета."
ADRLang.ru[Reward.LangPhrase] = "Используйте уникальный идентификатор предмета."
ADRLang.fr[Reward.LangPhrase] = "Utiliser un identifiant unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie einen eindeutigen Artikelbezeichner."
ADRLang.pl[Reward.LangPhrase] = "Użyj unikalnego identyfikatora elementu."
ADRLang.tr[Reward.LangPhrase] = "Benzersiz bir öğe tanımlayıcısı kullanın."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilizar un identificador único de artículo."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if VoidCases then return true end
	return false
end


ADRewards.CreateReward(Reward)