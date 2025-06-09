local Reward = {}

Reward.Name = "AShop Case"

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
        	if ashop.object_types[v.object_types].UniqueIdentifier == "CaseOpening" then akey = v.id break end
        end
    end


    local model = akey and ashop.items[akey].metadata[1] or false
    net.WriteBool(model)
    if model then
  		net.WriteString( model )
        net.WriteUInt(ashop.items[akey].rarity, 5)


        local sticker = ashop.items[akey].metadata[4] or false
        net.WriteBool(sticker)
        if sticker then
            net.WriteString( sticker )
        end

        local color1 = ashop.items[akey].metadata[5]
        net.WriteBool(color1)
        if color1 then
            net.WriteColor(color1, false)
        end

        local color2 = ashop.items[akey].metadata[6]
        net.WriteBool(color2)
         if color2 then
            net.WriteColor(color2, false)
        end

        local body = ashop.items[akey].metadata[7] or false
        net.WriteBool(body)
        if body then
            net.WriteString( body )
        end

        local colorized = ashop.items[akey].metadata[78] or false
        net.WriteBool(colorized)
        if colorized then
            net.WriteString( colorized )
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

local function findMat(mdl, name)
    for k, v in ipairs(mdl:GetMaterials()) do
        if string.find(v, name) then
            return k
        end
    end
end

Reward.DrawFunc = function(key, parent)
	local item = ashop.items[key] or Reward.List[key] or nil
	if !item then return end

    local itemBgClr = ashop.GetColor('ItemBg')
    local itemBgClrR, itemBgClrG, itemBgClrB = ashop.GetColor('ItemBg'):Unpack()
    local rarity = ashop.rarity[item.rarity]
    local rarityStyle = ashop.itemShopEffects[rarity.style]
    local cR = ashop.rarity[item.rarity]

    local mW, mH = parent:GetWide(), parent:GetTall()
    local SpawnI = vgui.Create( "DModelPanel" , parent ) -- SpawnIcon
    SpawnI:SetPos( mW*0.10, mH*0.10 )
    SpawnI:SetSize( mW*0.80, mH*0.80 )
    SpawnI:SetModel( item.metadata[1] ) -- Model we want for this spawn icon
    SpawnI:SetMouseInputEnabled(false)

    local mn, mx = SpawnI.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    SpawnI:SetFOV( 40 )
    SpawnI:SetCamPos( Vector( -size, size*1.5, size ) )
    SpawnI:SetLookAt( (mn + mx) * 0.5 )

    if item.metadata[5] then
        SpawnI.Entity.AShopCase = item.metadata[5]
    end

    if item.metadata[6] then
        SpawnI.Entity.AShopCase2 = item.metadata[5]
    end

    function SpawnI:LayoutEntity(ent)
        return 
    end

    for k, v in pairs({
        [4] = {findMat(SpawnI:GetEntity(), "sticker")},
        [7] = {findMat(SpawnI:GetEntity(), "body")},
        [8] = {findMat(SpawnI:GetEntity(), "colorized")}
    }) do
        if item.metadata[k] and IsValid(SpawnI) then
            local removeFunc = ashop.ui.setMaterialByLink(item.metadata[k], {
                ["$translucent"] = 1,
                ["$vertexalpha"] = 1,
                ["$vertexcolor"] = 1
            }, function(mat)
                mat = mat

                if isfunction(mat) then
                    local thinkFunc = SpawnI.LayoutEntity

                    function SpawnI:LayoutEntity(ent)
                        local mat = mat()

                        for i, j in ipairs(v) do
                            ent:SetSubMaterial(j-1, "!" .. mat:GetName())
                        end

                        if thinkFunc then
                            return thinkFunc(self, ent)
                        end
                    end
                else
                    if !IsValid(SpawnI.Entity) then return end

                    for i, j in ipairs(v) do
                        SpawnI.Entity:SetSubMaterial(j-1, "!" .. mat:GetName())
                    end
                end
            end)

            if removeFunc then
                local f = SpawnI.OnRemove
                function SpawnI:OnRemove()
                    removeFunc()

                    if f then f(self) end
                end
            end
        end
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

Reward.DrawKey = "Case Name"

Reward.GetKey = function(name)
	local key
	for k, v in pairs(ashop.items) do
        if v.name == name then
        	if ashop.object_types[v.object_types].UniqueIdentifier == "CaseOpening" then akey = v.id break end
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

    local sticker = net.ReadBool() and net.ReadString() or nil

    local color1 = net.ReadBool() and net.ReadColor(false) or nil

    local color2 = net.ReadBool() and net.ReadColor(false) or nil

    local body = net.ReadBool() and net.ReadString() or nil

    local colorized = net.ReadBool() and net.ReadString() or nil

	Reward.List[rewardVal] = {
		["metadata"] = {
			[1] = val,
            [4] = sticker,
            [5] = color1,
            [6] = color2,
            [7] = body,
            [8] = colorized,
		},
        ["rarity"] = rarity
	}

	return rewardVal
end

Reward.LangPhrase = "AShop_Case_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the case. The name must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву скриньки. Назва має бути унікальною."
ADRLang.ru[Reward.LangPhrase] = "Используйте имя ящика. Имя должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom de la boîte. Le nom doit être unique."
ADRLang.de[Reward.LangPhrase] = "KeVerwenden Sie den Namen der Box. Der Name muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy pola. Nazwa musi być unikalna."
ADRLang.tr[Reward.LangPhrase] = "Kutunun adını kullanın. İsim benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice el nombre de la casilla. El nombre debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if !ashop then return false end
	return true
end

ADRewards.CreateReward(Reward)