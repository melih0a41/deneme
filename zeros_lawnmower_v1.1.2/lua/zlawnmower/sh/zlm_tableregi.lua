/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

zlm = zlm or {}
zlm.f = zlm.f or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d

function zlm.f.Create_Grass(ID, _Model, Scale_min, Scale_max)
	local atable = {
		id = ID,
		model = _Model,
		s_min = Scale_min,
		s_max = Scale_max
	}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	util.PrecacheModel(_Model)
	table.insert(zlm.Grass, atable)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad
