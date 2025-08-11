---
--- Config entites code
---
perfectVault.Core.Entites = perfectVault.Core.Entites or {}
function perfectVault.Core.RegisterEntity(class, data, model)
	perfectVault.Core.Entites[class] = {}
	perfectVault.Core.Entites[class].cache = {}
	perfectVault.Core.Entites[class].config = data
	perfectVault.Core.Entites[class].model = model
end


function perfectVault.Core.GetEntityConfigOptions(class)
	return perfectVault.Core.Entites[class].config
end

if SERVER then return end

function perfectVault.Core.RequestConfigData(entity)
	net.Start("pvault_requestdata_send")
		net.WriteEntity(entity)
	net.SendToServer()
end

net.Receive("pvault_requestdata_response", function()
	local ent = net.ReadEntity()
	if not ent then return end

	local data = net.ReadTable()
	ent.data = data
	ent:PostData()
end)