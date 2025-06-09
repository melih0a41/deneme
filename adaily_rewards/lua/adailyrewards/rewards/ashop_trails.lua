local Reward = {}

Reward.Name = "AShop Trails"

Reward.MaxAmount = 1

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	local aid
	for k, v in pairs(ashop.items) do
        if v.name == key then
            aid = v.id
            break
        end
    end
    if !aid then return end
	ashop.actions.Give(ply, aid, nil, 0, false)
end

Reward.NetWrite = function(rewardVal)
	local akey
	for k, v in pairs(ashop.items) do
        if v.name == rewardVal then
            if ashop.object_types[v.object_types].UniqueIdentifier == "Trails" then akey = v.id break end
        end
    end


    local matString = akey and ashop.items[akey].metadata[2] or false
    net.WriteBool(matString)
    if matString then
    	net.WriteString(matString)
    	net.WriteUInt(ashop.items[akey].rarity, 5)
    end
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.List = {}

Reward.DrawType = 4 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

local grad = Material('akulla/gradient-d')
local circle = Material('akulla/circle.png', 'smooth')

Reward.DrawFunc = function(key, parent)
	local item = ashop.items[key] or Reward.List[key] or nil
	if !item then return end

	local itemBgClr = ashop.GetColor('ItemBg')
    local itemBgClrR, itemBgClrG, itemBgClrB = ashop.GetColor('ItemBg'):Unpack()
    local rarity = ashop.rarity[item.rarity]
    local rarityStyle = ashop.itemShopEffects[rarity.style]
    local cR = ashop.rarity[item.rarity]

    local mW, mH = parent:GetWide(), parent:GetTall()

	matPanel = vgui.Create( "DPanel", parent)
	matPanel:SetPos( mW*0.10, mH*0.10 )
	matPanel:SetSize( mW*0.80, mH*0.80 )

	local r1
	matPanel.Paint = function(self, w, h)
		if !self.outlinedItemBox then
            self.outlinedItemBox, self.polyshape = ashop.ui.RoundedBoxOutlined(self.OutlineOverride or ashop.Config.round, 0, 0, w, h, itemBgClr, rarity.clr, 2, function()
                surface.SetMaterial(grad)
                surface.SetDrawColor(cR.r, cR.g, cR.b, 25)
                surface.DrawTexturedRect(0, h*0.6, w, h*0.4 )
            end)
        end

        ashop.StartStencil()
            draw.NoTexture()
            surface.SetDrawColor(itemBgClrR, itemBgClrG, itemBgClrB, 150)
            surface.DrawPoly(self.polyshape)

            ashop.ReplaceStencil(1)

            surface.SetDrawColor(cR.r, cR.g, cR.b, 100)
            surface.SetMaterial(circle)
            surface.DrawTexturedRect(0, 0, w, w)


            if rarityStyle and rarityStyle.preDraw then
                rarityStyle.preDraw(self, w, h, false, rarity.clr)
            end
        ashop.EndStencil()


		if !r1 then
            r1 = ashop.ui.RoundedBox(ashop.Config.round, w*0.10, h*0.10, w*0.8, h*0.8)
        end

        ashop.StartStencil()
            surface.SetDrawColor(1,1,1,1)
            draw.NoTexture()
            surface.DrawPoly(r1)
        ashop.ReplaceStencil(1)
            surface.SetDrawColor(255, 255, 255)
            surface.SetTexture(surface.GetTextureID(item.metadata[2]))
            surface.DrawTexturedRect(w*0.15, h*0.10, w*0.8, h*0.8)
        ashop.EndStencil()
	end

	return matPanel
end

Reward.DrawKey = "Trail Name"

Reward.GetKey = function(name)
	local key
	for k, v in pairs(ashop.items) do
        if v.name == name then
            if ashop.object_types[v.object_types].UniqueIdentifier == "Trails" then akey = v.id break end
        end
    end
    if !key then
    	if Reward.List[name] then key = name end
    end
	return key
end

Reward.NetRead = function(rewardVal)
	local valid = net.ReadBool()
	if !valid then return end
	local val = net.ReadString()
	local rarity = net.ReadUInt(5)

	Reward.List[rewardVal] = {
		["metadata"] = {
			[2] = val,
		},
		["rarity"] = rarity
	}
	return rewardVal
end

Reward.LangPhrase = "AShop_Trails_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the tail. The name must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву хвоста. Назва має бути унікальною."
ADRLang.ru[Reward.LangPhrase] = "Используйте имя хвоста. Имя должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom de la queue. Le nom doit être unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen des Schwanzes. Der Name muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy ogona. Nazwa musi być unikalna."
ADRLang.tr[Reward.LangPhrase] = "Kuyruğun adını kullanın. İsim benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice el nombre de la cola. El nombre debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if !ashop then return false end
	return true
end

ADRewards.CreateReward(Reward)