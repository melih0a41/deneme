local Reward = {}

Reward.Name = "AShop Weapon Permanent"

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
        	if ashop.object_types[v.object_types].UniqueIdentifier == "PermanentWeapons" then akey = v.id break end
        end
    end


    local model = akey and ashop.items[akey].metadata[1] or false
    net.WriteBool(model)
    if model then
  		net.WriteString( model )
        net.WriteUInt(ashop.items[akey].rarity, 5)

        local vec = false
        if ashop.items[akey].metadata[4] then
            vec = ashop.items[akey].metadata[4]
        end
        net.WriteBool(vec)
        if vec then
            net.WriteVector( vec )
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

    local wep = weapons.Get(item.metadata[1]) or ashop.DefaultWeaponsHL2[item.metadata[1]]
    local key

    if string.find(item.metadata[1], 'fas2') then
        key = "WM"
    elseif ashop.DefaultWeaponsHL2[item.metadata[1]] then
        key = 1
    else
        key = "WorldModel"
    end

    if !wep then return end

    local mW, mH = parent:GetWide(), parent:GetTall()
    local m = vgui.Create( "DModelPanel" , parent )
    m:SetPos( mW*0.10, mH*0.10 )
    m:SetSize( mW*0.80, mH*0.80 )

    m:SetModel( wep[key] )
    m:SetMouseInputEnabled(false)

    m.FarZ = 4096*10

    local mn, mx = m.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    m:SetFOV( 45 )
    m:SetLookAt( (mn + mx) * 0.5 )
    m:SetCamPos( Vector(size, size, 0))

    function m:LayoutEntity() end

    function m:PreDrawModel(ent)
        render.SetLightingMode(1)
    end

    function m:PostDrawModel(ent)
        render.SetLightingMode(0)
    end

    if item.metadata[4] then
        m:SetCamPos(item.metadata[4])
    end

    local oldPaint = m.Paint
    function m:Paint(w, h)
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

        oldPaint(m, w, h)
    end

    return m
end

Reward.DrawKey = "Weapon Name"

Reward.GetKey = function(name)
	local key
	for k, v in pairs(ashop.items) do
        if v.name == name then
        	if ashop.object_types[v.object_types].UniqueIdentifier == "PermanentWeapons" then akey = v.id break end
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

    local vec = net.ReadBool()
    if vec then
        vec = net.ReadVector()
    end

	Reward.List[rewardVal] = {
		["metadata"] = {
			[1] = val,
            [4] = vec or nil,
		},
        ["rarity"] = rarity
	}

	return rewardVal
end

Reward.LangPhrase = "AShop_Weapon_Permanent_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the weapon (not the class). The name must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву зброї (не клас). Назва повинна бути унікальною."
ADRLang.ru[Reward.LangPhrase] = "Используйте название оружия (не класс). Название должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom de l'arme (et non la classe). Le nom doit être unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen der Waffe (nicht der Klasse). Der Name muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy broni (nie klasy). Nazwa musi być unikalna."
ADRLang.tr[Reward.LangPhrase] = "Silahın adını kullanın (sınıfını değil). İsim benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utiliza el nombre del arma (no la clase). El nombre debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if !ashop then return false end
	return true
end

ADRewards.CreateReward(Reward)