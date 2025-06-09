local Reward = {}

Reward.Name = "AShop Weapon Skin"

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
        	if ashop.object_types[v.object_types].UniqueIdentifier == "WeaponSkins" then akey = v.id break end
        end
    end


    local model = akey and ashop.items[akey].metadata[1] or false
    net.WriteBool(model)
    if model then
  		net.WriteString( model )
    end
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.List = {}

Reward.DrawType = 4 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key, parent)
	local item = ashop.items[key] or Reward.List[key] or nil
	if !item then return end

	local mW, mH = parent:GetWide(), parent:GetTall()
	local SpawnI = vgui.Create( "DModelPanel" , parent )
    SpawnI:SetPos( mW*0.13, mH*0.13 )
	SpawnI:SetSize( mW*0.76, mH*0.76 )

    // What an hack...
    local vmt = file.Read("materials/" .. item.metadata[1] .. ".vmt", 'GAME')
    local t = {
        ["$basetexture"] = item.metadata[1]
    }

    if vmt and string.find(vmt, 'AnimatedTexture') then
        t['Proxies'] = {
            ["AnimatedTexture"] = {
                ["animatedTextureVar"] = "$basetexture",
                ["animatedTextureFrameNumVar"] = "$frame",
                ["animatedTextureFrameRate"] = 30
            }
        }
    elseif vmt and string.find(vmt, 'TextureScroll') then
        t['Proxies'] = {
            ["TextureScroll"] = {
                ["texturescrollvar"] = "$baseTextureTransform",
                ["texturescrollrate"] = 0.1,
                ["texturescrollangle"] = 130
            }
        }
    end

    local mat = CreateMaterial('ashop_weptex_' .. item.metadata[1], "UnLitGeneric", t)
    
    local r1
    function SpawnI:Paint(w, h)
        if !r1 then
            r1 = ashop.ui.RoundedBox(ashop.Config.round, 0, 0, w, h)
        end

        ashop.StartStencil()
            surface.SetDrawColor(1, 1, 1, 1)
            draw.NoTexture()
            surface.DrawPoly(r1)
        ashop.ReplaceStencil(1)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(0, 0, w, h)
        ashop.EndStencil()
    end

    return SpawnI
end

Reward.DrawKey = "Name of Skin"

Reward.GetKey = function(name)
	local key
	for k, v in pairs(ashop.items) do
        if v.name == name then
        	if ashop.object_types[v.object_types].UniqueIdentifier == "WeaponSkins" then akey = v.id break end
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

	Reward.List[rewardVal] = {
		["metadata"] = {
			[1] = val,
		}
	}

	return rewardVal
end

Reward.LangPhrase = "AShop_Weapon_Skin_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the item. The name must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву предмету. Назва повинна бути унікальною."
ADRLang.ru[Reward.LangPhrase] = "Используйте имя предмета. Имя должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom de l'article. Le nom doit être unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen des Artikels. Der Name muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy elementu. Nazwa musi być unikalna."
ADRLang.tr[Reward.LangPhrase] = "Öğenin adını kullanın. İsim benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice el nombre del artículo. El nombre debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if !ashop then return false end
	return true
end

ADRewards.CreateReward(Reward)