local Reward = {}

Reward.Name = "AShop Pets"

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
            if ashop.object_types[v.object_types].UniqueIdentifier == "Pets" then akey = v.id break end
        end
    end


    local model = akey and ashop.items[akey].metadata[1] or false
    net.WriteBool(model)
    if model then
    	net.WriteString( model )
    	net.WriteUInt(ashop.items[akey].rarity, 5)

    	local rskin = ashop.items[akey].metadata[2] or false
    	if !isnumber(rskin) then rskin = false end
    	net.WriteBool(rskin)
    	if rskin then
    		net.WriteUInt(rskin, 5)
    	end
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

	local SpawnI = vgui.Create( "SpawnIcon" , parent ) -- SpawnIcon
    SpawnI:SetPos( mW*0.10, mH*0.10 )
	SpawnI:SetSize( mW*0.80, mH*0.80 )
    SpawnI:SetModel( item.metadata[1], item.metadata[2] ) -- Model we want for this spawn icon
    SpawnI:SetMouseInputEnabled(false)
    if item.metadata[2] then
        SpawnI:SetSkin(item.metadata[2])
    end

    local oldPaint = SpawnI.Paint
    function SpawnI:Paint(w, h)
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

        oldPaint(SpawnI, w, h)
    end

    return SpawnI
end

Reward.DrawKey = "Pet Name"

Reward.GetKey = function(name)
	local key
	for k, v in pairs(ashop.items) do
        if v.name == name then
            if ashop.object_types[v.object_types].UniqueIdentifier == "Pets" then akey = v.id break end
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

	local rskin = net.ReadBool()
	if rskin then
		rskin = net.ReadUInt(5)
	end


	Reward.List[rewardVal] = {
		["metadata"] = {
			[1] = val,
			[2] = rskin or 0,
		},
		["rarity"] = rarity
	}

	return rewardVal
end

Reward.LangPhrase = "AShop_Pets_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the pet. The name must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву вихованця. Назва має бути унікальною."
ADRLang.ru[Reward.LangPhrase] = "Используйте имя питомца. Имя должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom de l'animal. Le nom doit être unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen des Haustieres. Der Name muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj imienia zwierzęcia. Nazwa musi być unikalna."
ADRLang.tr[Reward.LangPhrase] = "Evcil hayvanın adını kullanın. İsim benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice el nombre de la mascota. El nombre debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if !ashop then return false end
	return true
end

ADRewards.CreateReward(Reward)