/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

include( "shared.lua" )

ENT.PrintName = "Money printer"
ENT.Category = "OnePrint"
ENT.Author = "Timmy & OGL"
ENT.Contact	= "http://steamcommunity.com/id/alshulgin"
ENT.Instructions = ""

--[[
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

    ENT:Draw

]]--

function ENT:DrawTranslucent()
	self:DrawModel()

    self.iLastCheck = ( self.iLastCheck or 0 )
	self.iDist = ( self.iDist or 10001 )

    if ( CurTime() > ( self.iLastCheck + 1 ) ) then
		self.iDist = LocalPlayer():GetPos():DistToSqr( self:GetPos() )
		self.iLastCheck = CurTime()
    end

	if ( self.iDist > 10000 ) then
		if IsValid( self.dPrinter ) then
			self.dPrinter:Remove()
			self.dPrinter = nil
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 119ae5788ce457cb9ed600b2a4a4cb0beb2aeff12114aedc40734066cacc5d67

		return
	end

	if not IsValid( self.dPrinter ) then
		self.dPrinter = OnePrint:Create3DUI( self )
		return
	end

	local tPos = self:GetPos()
	tPos = tPos + ( self:GetUp() * 61.9 ) + ( self:GetForward() * 21.9 ) + ( self:GetRight() * 11.25 )

	local tAng = self:GetAngles()
	tAng:RotateAroundAxis( tAng:Forward(), 90 )
	tAng:RotateAroundAxis( tAng:Right(), -90 )
	tAng:RotateAroundAxis( tAng:Forward(), -15 )

	vgui.Start3D2D( tPos, tAng, .0384 )
		self.dPrinter:Paint3D2D()
	vgui.End3D2D()
end

--[[

	ENT:OnVarChanged

]]--

function ENT:OnVarChanged( sVar, xOld, xNew )
	if ( sVar == "CurrentTab" ) then
		self:SetTab( xNew )
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

--[[

	ENT:SetTab

]]--

function ENT:SetTab( iTab )
	if IsValid( self.dPrinter ) then
		OnePrint:SetTab( self.dPrinter, iTab )
	end
end

--[[

	ENT:OnRemove
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:OnRemove()
	if IsValid( self.dPrinter ) then
		self.dPrinter:Remove()
		self.dPrinter = nil
	end
end
