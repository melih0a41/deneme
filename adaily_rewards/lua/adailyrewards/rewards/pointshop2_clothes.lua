local Reward = {}

Reward.Name = "PS2 Clothes"

Reward.MaxAmount = 1

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	if !key then return end
	local itemClass = Pointshop2.GetItemClassByPrintName( key )
    ply:PS2_EasyAddItem( itemClass.className )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 4 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

local c_bg = Color(51,51,51)
Reward.DrawFunc = function(key, parent)
	if !key then return end
	local itemClass = Pointshop2.GetItemClassByPrintName( key )
	local pW, pH = parent:GetSize()

	local itemPanel = vgui.Create( "DPanel", parent )
	itemPanel:SetPos( pW*0.1+1, pH*0.1+1 )
	itemPanel:SetSize( pW*0.8, pH*0.8 )
	itemPanel.Paint = function(self, w, h)
		ADRewards.draw_RoundedTextureBox(8, 0, 0, w, h, c_bg)
	end


	local ipW, ipH = itemPanel:GetSize()
	local itemIcon
	if itemClass.iconInfo.shop.useMaterialIcon then
		--The Newman Badge
		itemIcon = vgui.Create( "DImage", itemPanel )
		itemIcon:SetPos( ipW*0.10, ipH*0.10 )
		itemIcon:SetSize( ipW*0.8, ipH*0.8 )
		if Material(itemClass.iconInfo.shop.iconMaterial) then
			itemIcon:SetImage( itemClass.iconInfo.shop.iconMaterial )
		end
	else
		itemIcon = vgui.Create( "DPreRenderedModelPanel", itemPanel )
		itemIcon:SetPos( ipW*0.05, ipH*0.05 )
		itemIcon:SetSize( ipW*0.9, ipH*0.9 )

		local model = Pointshop2:GetPreviewModel()
		itemIcon:ApplyModelInfo( model )

		local outfit = itemClass.getOutfitForModel(model.model)
		itemIcon:SetPacOutfit( outfit )

		local viewInfo = itemClass.iconInfo.inv.iconViewInfo
		itemIcon:SetViewInfo( viewInfo )

		itemIcon.PaintActual = function(self, w, h)
			if not IsValid( self.Entity ) or
			   not self.pacOutfit or
			   not self.viewInfo then
				return
			end

			local x, y = self:LocalToScreen( 0, 0 )

			pac.FrameNumber = pac.FrameNumber + 100
			if pac.Think then pac.Think() end
			
			cam.Start3D( self.viewInfo.origin, self.viewInfo.angles, self.viewInfo.fov - 20, 0, 0, w, h, 5, 4096 )
				cam.IgnoreZ( true )
				render.SuppressEngineLighting( true )
				render.SetLightingOrigin( self.Entity:GetPos() )
				render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
				render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
				render.SetBlend( self.colColor.a/255 )

				for i=0, 6 do
					local col = self.DirectionalLight[ i ]
					if ( col ) then
						render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
					end
				end

				draw_localplayer = true
				pac.FlashlightDisable( true )
					pac.RenderOverride( self.Entity, "opaque" )
					pac.RenderOverride( self.Entity, "translucent", true )
					self.Entity:DrawModel( )
					pac.RenderOverride( self.Entity, "translucent", true )
				pac.FlashlightDisable( false )
				draw_localplayer = false

				cam.IgnoreZ( false )
				render.SuppressEngineLighting( false )
			cam.End3D( )
		end
		itemIcon.Paint = function(self, w, h)
			if not self.rt then
				local uid = "PS2RT_PreRender" .. math.random( 0, 1000000000 ) --not the cleanest but should work
				self.rt = GetRenderTarget( uid, 256, 256 )
				self.mat = CreateMaterial( uid .. "mat", "UnlitGeneric", {
					["$basetexture"] = self.rt,
					--["$vertexcolor"] = 1,
					--["$vertexalpha"] = 1
				} )
			end

			if not self.dirty and not self.forceRender then
				self:PaintCached( w, h )
				return
			end

			render.PushRenderTarget(self.rt, 0, 0, 256, 256)
				local oldW, oldH = ScrW(), ScrH()
				local x,y = 0, 0 -- self:LocalToScreen(0, 0)
				render.Clear( 47, 47, 47, 255, true, true )
				-- render.SetViewPort(x, y, w, h)
				-- cam.Start2D()
				self:PaintActual( 256, 256 )
				-- cam.End2D()
				-- render.SetViewPort( 0, 0, oldW, oldH )
			render.PopRenderTarget()

			self.mat:SetTexture( "$basetexture", self.rt )

			self:PaintCached( w, h )

			self.LastPaint = RealTime()
			self.framesDrawn = self.framesDrawn or 0
			self.framesDrawn = self.framesDrawn + 1
			if self.framesDrawn > 10 then
				self.dirty = false
			end
		end
	end

	itemIcon:SetMouseInputEnabled( false )

	return itemPanel
end

Reward.DrawKey = "Clothes Name"

Reward.GetKey = function(name)
	local key = false
	local getItem = Pointshop2.GetItemClassByPrintName( name ) or false
	if getItem then
		if getItem.super != KInventory.Items.base_hat then return false end
		key = name
	end
	return key
end

Reward.LangPhrase = "PS2_Clothes_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the clothing item. The name must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву елемента одягу. Ім'я має бути унікальним"
ADRLang.ru[Reward.LangPhrase] = "Используйте имя элемента одежды. Имя должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom de l'article vestimentaire. Le nom doit être unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen des Kleidungsstücks. Der Name muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy elementu odzieży. Nazwa musi być unikalna."
ADRLang.tr[Reward.LangPhrase] = "Giyim eşyasının adını kullanın. İsim benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice el nombre de la prenda. El nombre debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if not Pointshop2 or (Pointshop2 and ashop) then return false end
	return true
end

ADRewards.CreateReward(Reward)