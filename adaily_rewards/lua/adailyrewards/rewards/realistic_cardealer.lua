local Reward = {}

Reward.Name = "Realistic Car Dealer"

Reward.MaxAmount = 1

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	RCD.GiveVehicle(ply, key)
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 4 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key, parent)
	local vehiclesTable = RCD.GetVehicles() or {}
	if !vehiclesTable[key] then return end

	local mW, mH = parent:GetWide(), parent:GetTall()

	local vehc = RCD.VehiclesList[vehiclesTable[key].class] or {}
    local model = vehc["Model"] or ""

    local vehicleModel = vgui.Create("RCD:DModel", parent)
    vehicleModel:SetPos( mW*0.10, mH*0.10 )
    vehicleModel:SetSize( mW*0.80, mH*0.70 )
	vehicleModel:SetModel(model)
    vehicleModel.PaintOver = function(self,w,h)
    end

    vehicleModel.DrawModel = function(self)
    	local curparent = self
        local leftx, topy = self:LocalToScreen(0, 0)
        local rightx, bottomy = self:LocalToScreen(self:GetWide(), self:GetTall())
        while (curparent:GetParent() != nil) do
            curparent = curparent:GetParent()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198243053650
    
            local x1, y1 = curparent:LocalToScreen(0, 0)
            local x2, y2 = curparent:LocalToScreen(curparent:GetWide(), curparent:GetTall())
    
            leftx = math.max(leftx, x1)
            topy = math.max(topy, y1)
            rightx = math.min(rightx, x2)
            bottomy = math.min(bottomy, y2)
            previous = curparent
        end
    
        render.SetScissorRect(leftx, topy, rightx, bottomy, true)
        
       if IsValid(vehicleModel.Vehicle) then
       		local v = vehicleModel.Vehicle
            local vehicleTable = v.RCDInfo or {}

            if IsValid(v) && v:GetModel() != v.model then
                v:SetModel(v.model)
            end
            local color = v.RCDColor or color_white

            render.SetColorModulation(color.r/255, color.g/255, color.b/255)
            v:DrawModel()

            if istable(v.wheels) then
                for k, wheel in ipairs(v.wheels) do
                    wheel:DrawModel()
                end
            end       
        end

        render.SetScissorRect(0, 0, 0, 0, false)
    end

    vehicleModel.Vehicle = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl", RENDER_GROUP_OPAQUE)
    
    vehicleModel.Vehicle:SetNoDraw(true)
    vehicleModel.Vehicle:SetPos(Vector(0,0,0))
    vehicleModel.Vehicle:AddEffects(EF_BONEMERGE)
    vehicleModel.Vehicle.RCDColor = RCD.Colors["white"]
    vehicleModel.Vehicle.RCDInfo = vehiclesTable[key]
    vehicleModel.Vehicle.model = model
    vehicleModel.Vehicle:SetModelScale(vehiclesTable[key].options.scale or 1)

    vehicleModel:SetParams(vehiclesTable[key].options, vehicleModel.Vehicle, true, true)

    if vehiclesTable[key].options["addon"] == "simfphys" then
        RCD.GenerateWheels(vehicleModel.Vehicle, vehiclesTable[key].class)
    end



    vehicleModel.FarZ = 4096*10
    local mn, mx = vehicleModel.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    vehicleModel:SetFOV( 35 )
    vehicleModel:SetLookAt( (mn + mx) * 0.5 )
    vehicleModel:SetCamPos( Vector(size, size, size))


    /*local mn, mx = vehicleModel.Entity:GetRenderBounds()
    vehicleModel:SetFOV( 50 )
    vehicleModel:SetLookAt( Vector(0, 0, 0) )
    vehicleModel:SetLookAng( Angle(30, -100, 0) )
    vehicleModel:SetCamPos( Vector(17, 200, 35-mn.z+mx.z))*/

    vehicleModel:SetMouseInputEnabled(false)


    return vehicleModel
end

Reward.DrawKey = "Car Name"

Reward.GetKey = function(name)
	local key = false
	local vehiclesTable = RCD.GetVehicles() or {}
	for k, v in pairs(vehiclesTable) do
		if v.name == name then
			key = k
			break
		end
	end
	return key
end

Reward.LangPhrase = "RCD_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the vehicle in the store. It must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву автівки в магазині. Вона має бути унікальною."
ADRLang.ru[Reward.LangPhrase] = "Используйте имя автомобиля. Оно должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom du véhicule dans le magasin. Il doit être unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen des Fahrzeugs in der Filiale. Er muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy pojazdu w sklepie. Musi być ona unikalna."
ADRLang.tr[Reward.LangPhrase] = "Mağazadaki aracın adını kullanın. Benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice el nombre del vehículo en la tienda. Debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if !RCD then return false end
	return true
end


ADRewards.CreateReward(Reward)