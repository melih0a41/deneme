/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

function ENT:Draw()
	self:DrawModel()
	zpiz.Sign.Draw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838599
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1e328fabbaf565eb0db586ac588b71f8384bcaa811ba77de699b4af9f3938eed
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

function ENT:DrawTranslucent()
	self:Draw()
end
