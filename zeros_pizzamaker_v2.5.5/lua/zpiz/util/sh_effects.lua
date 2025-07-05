/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

zpiz = zpiz or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1e328fabbaf565eb0db586ac588b71f8384bcaa811ba77de699b4af9f3938eed

zclib.NetEvent.AddDefinition("zpiz_customer_sit", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Animation.Play(ent, "d1_t03_sit_bed", 1)
end, true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac

zclib.NetEvent.AddDefinition("zpiz_customer_sit_random", {
	[1] = {
		type = "entity"
	},
	[2] = {
		type = "uiint"
	}
}, function(received)
	local ent = received[1]
	local customerDataID = received[2]
	if customerDataID == nil then return end
	if not IsValid(ent) then return end
	local customerData = zpiz.config.Customers[customerDataID]
	local sitAnim = customerData.SitAnim[math.random(#customerData.SitAnim)]
	zclib.Animation.Play(ent, sitAnim, 1)
end, true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

zclib.NetEvent.AddDefinition("zpiz_customer_serv_random", {
	[1] = {
		type = "entity"
	},
	[2] = {
		type = "uiint"
	}
}, function(received)
	local ent = received[1]
	local customerDataID = received[2]
	if customerDataID == nil then return end
	if not IsValid(ent) then return end
	local customerData = zpiz.config.Customers[customerDataID]
	local ServAnim = customerData.ServAnim[math.random(#customerData.ServAnim)]
	zclib.Animation.Play(ent, ServAnim, 1)
end, true)

zclib.NetEvent.AddDefinition("zpiz_oven_open", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Animation.Play(ent, "open", 1)
end, true)

zclib.NetEvent.AddDefinition("zpiz_oven_close", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Animation.Play(ent, "close", 1)
end, true)

zclib.NetEvent.AddDefinition("zpiz_pizza_bake", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Effect.ParticleEffect("zpizmak_oven_main", ent:GetPos(), ent:GetAngles(), ent)
end, true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1e328fabbaf565eb0db586ac588b71f8384bcaa811ba77de699b4af9f3938eed
