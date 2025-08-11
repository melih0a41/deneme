--[[---------------------------------------------------------
	Name: Setup
-----------------------------------------------------------]]

AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

--[[---------------------------------------------------------
	Name: Entity
-----------------------------------------------------------]]

function ENT:Initialize()
    self:SetModel( VoidCases.Config.NPCModel )
    self:SetHullType( HULL_HUMAN )
    self:SetHullSizeNormal()
    self:SetNPCState( NPC_STATE_SCRIPT )
    self:SetSolid( SOLID_BBOX )
    bit.bor( CAP_ANIMATEDFACE , CAP_TURN_HEAD)
    self:SetUseType( SIMPLE_USE )
    self:DropToFloor()

    self:SetMaxYawSpeed( 5000 )
end

function ENT:OnTakeDamage()
    return 0
end

function ENT:AcceptInput( Name, Activator, Caller )
    Activator:ConCommand("voidcases")
end
