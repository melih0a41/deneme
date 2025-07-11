/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if SERVER then return end
zlm = zlm or {}
zlm.f = zlm.f or {}

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

function zlm.f.Player_Initialize()
	zlm.f.Debug("zlm.f.Player_Initialize")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

	net.Start("zlm_Player_Initialize")
	net.SendToServer()
end

// Sends a net msg to the server that the player has fully initialized and removes itself
hook.Add("HUDPaint", "a_zlm_PlayerInit_HUDPaint", function()
	zlm.f.Debug("zlm_PlayerInit_HUDPaint")

	zlm.f.Player_Initialize()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	hook.Remove("HUDPaint", "a_zlm_PlayerInit_HUDPaint")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2
