/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

function ENT:Initialize()
	zpiz.Plate.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac

function ENT:Draw()
	self:DrawModel()
	zpiz.Plate.Draw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1e328fabbaf565eb0db586ac588b71f8384bcaa811ba77de699b4af9f3938eed

function ENT:DrawTranslucent()
	self:Draw()
end
