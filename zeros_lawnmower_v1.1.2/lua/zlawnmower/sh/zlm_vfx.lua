/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

zlm = zlm or {}
zlm.f = zlm.f or {}

if SERVER then
	--Effects
	util.AddNetworkString("zlm_FX")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

	function zlm.f.CreateEffectAtPos(effect, position)
		net.Start("zlm_FX")
		net.WriteString(effect)
		net.WriteVector(position)
		net.SendPVS(position)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

if CLIENT then
	-- Effects
	net.Receive("zlm_FX", function(len)
		local effect = net.ReadString()
		local pos = net.ReadVector()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

		if effect and pos then
			ParticleEffect(effect, pos, Angle(0, 0, 0), NULL)
		end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad
