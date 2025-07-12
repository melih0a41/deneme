/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if not SERVER then return end
zlm = zlm or {}
zlm.f = zlm.f or {}


if zlm_BuyerNPCs == nil then
	zlm_BuyerNPCs = {}
end

function zlm.f.Add_BuyerNPC(npc)
	table.insert(zlm_BuyerNPCs, npc)
end


function zlm.f.Check_BuyerMarkt_TimerExist()
	if timer.Exists("zlm_buyermarkt_id") == false and zlm.config.NPC.RefreshRate ~= -1 then
		zlm.f.Timer_Create("zlm_buyermarkt_id", zlm.config.NPC.RefreshRate, 0, zlm.f.ChangeMarkt)
	end
end

timer.Simple(0,function()
	zlm.f.Check_BuyerMarkt_TimerExist()
end)

function zlm.f.ChangeMarkt()
	for k, v in pairs(zlm_BuyerNPCs) do
		if (IsValid(v)) then
			v:RefreshBuyRate()
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	zlm.f.Debug("NPCs Updated!")
end


// The SAVE / LOAD Functions
concommand.Add("zlm_save_buyernpc", function(ply, cmd, args)
	if IsValid(ply) and zlm.f.IsAdmin(ply) then
		zlm.f.Save_BuyerNPC()
		zlm.f.Notify(ply, "Grass Buyer NPC´s have been saved for the map " .. game.GetMap() .. "!", 0)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

concommand.Add("zlm_remove_buyernpc", function(ply, cmd, args)
	if IsValid(ply) and zlm.f.IsAdmin(ply) then
		zlm.f.Remove_BuyerNPC()
		zlm.f.Notify(ply, "Grass Buyer NPC´s have been removed for the map " .. game.GetMap() .. "!", 0)
	end
end)

function zlm.f.Save_BuyerNPC()
	local data = {}

	for u, j in pairs(ents.FindByClass("zlm_buyer_npc")) do
		table.insert(data, {
			pos = j:GetPos(),
			ang = j:GetAngles()
		})
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

	if not file.Exists("zlm", "DATA") then
		file.CreateDir("zlm")
	end

	file.Write("zlm/" .. string.lower(game.GetMap()) .. "_buyernpcs" .. ".txt", util.TableToJSON(data))
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

function zlm.f.Load_BuyerNPC()
	if file.Exists("zlm/" .. string.lower(game.GetMap()) .. "_buyernpcs" .. ".txt", "DATA") then
		local data = file.Read("zlm/" .. string.lower(game.GetMap()) .. "_buyernpcs" .. ".txt", "DATA")
		data = util.JSONToTable(data)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

		if data and table.Count(data) > 0 then
			for k, v in pairs(data) do
				local npc = ents.Create("zlm_buyer_npc")
				npc:SetPos(v.pos)
				npc:SetAngles(v.ang)
				npc:Spawn()
				npc:Activate()
			end

			print("[Zeros LawnMower] Finished loading Buyer NPCs.")
		end
	else
		print("[Zeros LawnMower] No map data found for BuyerNPCs entities. Please place some and do !savezlm to create the data.")
	end
end

function zlm.f.Remove_BuyerNPC()
	if file.Exists("zlm/" .. string.lower(game.GetMap()) .. "_buyernpcs" .. ".txt", "DATA") then
		file.Delete("zlm/" .. string.lower(game.GetMap()) .. "_buyernpcs" .. ".txt")
	end

	for k, v in pairs(ents.FindByClass("zlm_buyer_npc")) do
		if IsValid(v) then
			v:Remove()
		end
	end
end

timer.Simple(0,function()
	zlm.f.Load_BuyerNPC()
end)
hook.Add("PostCleanupMap", "a_zlm_SpawnBuyerNPCPostCleanUp", zlm.f.Load_BuyerNPC)
