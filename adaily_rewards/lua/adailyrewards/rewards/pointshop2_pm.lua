local Reward = {}

Reward.Name = "PS2 Playermodels"

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
	local itemIcon = vgui.Create( "DPointshopPlayerModelInvIcon", itemPanel )
	itemIcon:SetPos( ipW*0.05, ipH*0.05 )
	itemIcon:SetSize( ipW*0.9, ipH*0.9 )

	itemIcon.PaintOver = function(self, w, h) end
	itemIcon:SetItem( itemClass )

	itemIcon.modelPanel.Paint = function(self, w, h)
		if ( !IsValid( self.Entity ) ) then return end

		local x, y = self:LocalToScreen( 0, 0 )
		local w, h = self:GetSize()

		self:LayoutEntity( self.Entity )

		local ang = self.aLookAngle
		if ( !ang ) then
			ang = (self.vLookatPos-self.vCamPos):Angle()
		end
		
		cam.Start3D( self.vCamPos, ang, 25, x, y, w, h, 5, self.FarZ )

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
			
			self:DrawModel()
			
			render.SuppressEngineLighting( false )
		cam.End3D()

		self.LastPaint = RealTime()
	end

	

	itemIcon:SetMouseInputEnabled( false )

	return itemPanel
end

Reward.DrawKey = "PM Name"

Reward.GetKey = function(name)
	local key = false
	local getItem = Pointshop2.GetItemClassByPrintName( name ) or false
	if getItem then
		if getItem.super != KInventory.Items.base_playermodel then return false end
		key = name
	end
	return key
end

Reward.LangPhrase = "PS2_Playermodel_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the player's model. The name must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте ім'я моделі гравця. Ім'я має бути унікальним."
ADRLang.ru[Reward.LangPhrase] = "Используйте имя модели игрока. Имя должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom du modèle de lecteur. Ce nom doit être unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen des Spielermodells. Der Name muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy modelu gracza. Nazwa musi być unikalna."
ADRLang.tr[Reward.LangPhrase] = "Oyuncunun modelinin adını kullanın. İsim benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utiliza el nombre del modelo de jugador. El nombre debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if not Pointshop2 or (Pointshop2 and ashop) then return false end
	return true
end

ADRewards.CreateReward(Reward)