/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros GenLab
//https://www.gmodstore.com/market/view/zero-s-genlab-disease-script

zvm.Definition.Add("zbl_flask", {
	OnItemDataCatch = function(data, ent)
		data.gentype = ent:GetGenType()
		data.genvalue = ent:GetGenValue()
		data.genname = ent:GetGenName()
		data.genpoints = ent:GetGenPoints()
		data.genclass = ent:GetGenClass()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetGenType(data.gentype)
		ent:SetGenValue(data.genvalue)
		ent:SetGenName(data.genname)
		ent:SetGenPoints(data.genpoints)
		ent:SetGenClass(data.genclass)
	end,
	OnItemDataName = function(data, ent) return ent:GetGenName() end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.gentype == data.gentype and compared_item.extraData.genvalue == data.genvalue end,
	ProductImageOverwrite = function(pnl, ItemData)
		if zbl and zbl.materials and IsValid(pnl) then
			local gen_type = ItemData.extraData.gentype
			local gen_value = ItemData.extraData.genvalue
			local image
			local col
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

			-- GenType 0 means the flask which got added is empty, which should never happen
			if gen_type == 0 then
				image = zbl.materials[ "zbl_icon_close" ]
				col = zbl.colors[ "sample_blue" ]
			elseif gen_type == 1 then
				image = zbl.materials[ "zbl_dna_icon" ]
				col = zbl.colors[ "sample_blue" ]
			elseif gen_type == 2 then
				if zbl.config.Vaccines[ gen_value ] and zbl.config.Vaccines[ gen_value ].isvirus then
					image = zbl.materials[ "zbl_virus_icon" ]
					col = zbl.colors[ "virus_red" ]
				else
					image = zbl.materials[ "zbl_abillity_icon" ]
					col = zbl.colors[ "abillity_yellow" ]
				end
			elseif gen_type == 3 then
				image = zbl.materials[ "zbl_cure_icon" ]
				col = zbl.colors[ "cure_green" ]
			end

			if image then
				pnl:SetMaterial(image)
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

			if col then
				pnl:SetImageColor(col)
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

			return true
		end
	end,
	IdleImageOverwrite = function(pnl, ItemData)
		if zbl and zbl.materials and IsValid(pnl) then
			local gen_type = ItemData.extraData.gentype
			local gen_value = ItemData.extraData.genvalue
			local image
			local col

			-- GenType 0 means the flask which got added is empty, which should never happen
			if gen_type == 0 then
				image = zbl.materials[ "zbl_icon_close" ]
				col = zbl.colors[ "sample_blue" ]
			elseif gen_type == 1 then
				image = zbl.materials[ "zbl_dna_icon" ]
				col = zbl.colors[ "sample_blue" ]
			elseif gen_type == 2 then
				if zbl.config.Vaccines[ gen_value ] and zbl.config.Vaccines[ gen_value ].isvirus then
					image = zbl.materials[ "zbl_virus_icon" ]
					col = zbl.colors[ "virus_red" ]
				else
					image = zbl.materials[ "zbl_abillity_icon" ]
					col = zbl.colors[ "abillity_yellow" ]
				end
			elseif gen_type == 3 then
				image = zbl.materials[ "zbl_cure_icon" ]
				col = zbl.colors[ "cure_green" ]
			end

			if image then
				pnl:SetMaterial(image)
			end

			if col then
				pnl:SetImageColor(col)
			end

			return true
		end
	end,
	BlockItemCheck = function(other, Machine)
		if other:GetGenType() <= 0 then return true end
	end,
	OnPackageItemSpawned = function(data, ent, ply)
		ent.FlaskOwner = ply
		zbl.Flask.Add(ply, ent)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

zvm.AllowedItems.Add("zbl_gasmask")
zvm.AllowedItems.Add("zbl_spray")
zvm.AllowedItems.Add("zbl_gun")
zvm.AllowedItems.Add("zbl_lab")
zvm.AllowedItems.Add("zbl_dna")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc
