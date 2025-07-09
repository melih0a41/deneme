/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Spawnable = true
ENT.AdminSpawnable = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

--[[

	ENT:SetupDataTables

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

local tNWInts = {
	"CurrentTab",
	"Money",
	"Income",
	"IncomeBonus",
	"Servers",
	"Storage",
	"Defense",
	"Watercooling",
	"Overclocking",
	"Power",
	"Security",
	"Silencer",
	"Temperature",
	"MaxTemperature",
	"NextOccur"
}

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "OwnerObject" )

	for k, v in ipairs( tNWInts ) do
		self:NetworkVar( "Int", ( k - 1 ), v )
	end

	self:NetworkVar( "Bool", 0, "Powered" )
	self:NetworkVar( "Bool", 1, "Frozen" )
	self:NetworkVar( "Bool", 2, "HackNotif" )
	self:NetworkVar( "Bool", 3, "LowHPNotif" )

	self:NetworkVar( "String", 0, "UnparsedUsers" )
	self:NetworkVar( "String", 1, "UnparsedIncomeLogs" )
	self:NetworkVar( "String", 2, "UnparsedActionsLogs" )

	if CLIENT then
		self:NetworkVarNotify( "CurrentTab", self.OnVarChanged )
	end

	if SERVER then
		self:NetworkVarNotify( "OwnerObject", self.OnVarChanged )
		self:NetworkVarNotify( "Servers", self.OnVarChanged )
		-- self:NetworkVarNotify( "Powered", self.OnVarChanged )
		-- self:NetworkVarNotify( "Frozen", self.OnVarChanged )
	end
end

--[[

	ENT:ParseJSON

]]--

function ENT:ParseJSON( sJSON )
	local sJSON, tData = sJSON, {}

    if sJSON and ( sJSON ~= "" ) then
        local t = util.JSONToTable( sJSON )
		if t and istable( t ) then
			tData = t
		end
    end

	return tData
end

--[[

	ENT:GetUsers

]]--

function ENT:GetUsers()
	local tUsers = {}
	for k, v in pairs( self:ParseJSON( self:GetUnparsedUsers() ) ) do
		local pPlayer = player.GetByAccountID( k )
		if pPlayer and IsValid( pPlayer ) then
			table.insert( tUsers, pPlayer )
		end
	end

	return tUsers
end

--[[

	ENT:IsLocked

]]--

function ENT:IsLocked()
	return ( ( self:GetCurrentTab() == 0 ) or ( self:GetCurrentTab() == 4 ) )
end

--[[

	ENT:IsStorageFull

]]--

function ENT:IsStorageFull()
	return ( self:GetMoney() >= self:GetStorage() )
end

--[[

	ENT:CanPlayerUse

]]--

function ENT:CanPlayerUse( pPlayer )
	if ( self:GetPos():DistToSqr( pPlayer:GetPos() ) > 10000 ) then
		return
	end

	if ( pPlayer:GetEyeTrace().Entity ~= self ) then
		return
	end

	if not self:IsLocked() then
		return true
	end

	if ( self:GetOwnerObject() == pPlayer ) then
		return true
	end

	for k, v in pairs( self:GetUsers() ) do
		if ( v == pPlayer ) then
			return true
		end
	end

	return false
end

--[[

	ENT:GetActionsHistory

]]--

function ENT:GetIncomeLogs()
	return self:ParseJSON( self:GetUnparsedIncomeLogs() )
end

--[[

	ENT:GetActionsHistory

]]--

function ENT:GetActionLogs()
	return self:ParseJSON( self:GetUnparsedActionsLogs() )
end

--[[

	ENT:GetMaxServers()

]]--

-- oneprint_v1.1.2/lua/entities/oneprint/shared.lua dosyasındaki
-- mevcut GetMaxServers fonksiyonunu bununla değiştirin

function ENT:GetMaxServers()
    local owner = self:GetOwnerObject()
    
    -- Eğer sahip geçerli değilse CPPI'den kontrol et
    if not IsValid(owner) or not owner.GetUserGroup then
        -- CPPI'den gerçek sahibi bulmaya çalış
        if self.CPPIGetOwner then
            local realOwner = self:CPPIGetOwner()
            if IsValid(realOwner) and realOwner.GetUserGroup then
                owner = realOwner
                -- SERVER tarafındaysa sahipliği güncelle
                if SERVER then
                    self:SetOwnerObject(realOwner)
                end
            else
                return 4  -- Normal oyuncu limiti
            end
        else
            return 4  -- Normal oyuncu limiti
        end
    end
    
    -- Sahip hala sunucuda mı kontrol et
    local isOwnerOnline = false
    for _, ply in ipairs(player.GetAll()) do
        if ply == owner or (IsValid(owner) and ply:SteamID64() == owner:SteamID64()) then
            isOwnerOnline = true
            -- Eğer farklı instance ise güncelle
            if SERVER and ply ~= owner then
                self:SetOwnerObject(ply)
                owner = ply
            end
            break
        end
    end
    
    -- Eğer sahip sunucuda değilse varsayılan limit döndür (printer'ı silme)
    if not isOwnerOnline then
        return 4
    end
    
    local sGroup = owner:GetUserGroup()
    if OnePrint.Cfg.ServerLimit[sGroup] then
        if OnePrint.Cfg.ServerLimit[sGroup] > 6 then
            return 6
        else
            return OnePrint.Cfg.ServerLimit[sGroup]
        end
    end
    
    return 4  -- Varsayılan normal oyuncu limiti
end
--[[

	ENT:GetMaxDefense()

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:GetMaxDefense()
	return OnePrint.Cfg.DefenseMax
end

--[[

	ENT:GetMaxDefense()

]]--

function ENT:GetMaxWatercooling()
	return ( self:GetPower() * 2 ) + self:GetServers()
end

--[[

	ENT:GetMaxOverclocking

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:GetMaxOverclocking()
	return ( self:GetServers() + self:GetPower() )
end

--[[

	ENT:GetMaxPower

]]--

function ENT:GetMaxPower()
	return self:GetServers()
end

--[[

	ENT:GetMaxSecurity

]]--

function ENT:GetMaxSecurity()
	if ( self:GetServers() == 0 ) then
		return 0
	end

	return OnePrint.Cfg.HackingSecurityMax
end

--[[

	ENT:GetMaxSilencer

]]--

function ENT:GetMaxSilencer()
	if ( self:GetServers() == 0 ) then
		return 0
	end

	return 6
end

--[[

	ENT:GetTotalIncome
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

]]--

function ENT:GetTotalIncome()
	local iIncome = self:GetIncome()

	return math.Round( iIncome + ( iIncome * ( self:GetIncomeBonus() * .01 ) ) )
end

--[[

	ENT:GetCondition

]]--

function ENT:GetCondition()
	return ( self:Health() * 100 / self:GetMaxHealth() )
end

--[[

	ENT:CanUpgrade

]]--

local tUpgrade = {
	[ 1 ] = function( ePrinter )
		return ( ePrinter:GetServers() < ePrinter:GetMaxServers() )
	end,
	[ 2 ] = function( ePrinter )
		return ( ePrinter:GetDefense() < ePrinter:GetMaxDefense() )
	end,
	[ 3 ] = function( ePrinter )
		return ( ePrinter:GetWatercooling() < ePrinter:GetMaxWatercooling() )
	end,
	[ 4 ] = function( ePrinter )
		return ( ePrinter:GetPower() < ePrinter:GetMaxPower() )
	end,
	[ 5 ] = function( ePrinter )
		return ( ePrinter:GetOverclocking() < ePrinter:GetMaxOverclocking() )
	end,
	[ 6 ] = function( ePrinter )
		return ( ePrinter:GetSecurity() < ePrinter:GetMaxSecurity() )
	end,
	[ 7 ] = function( ePrinter )
		return ( ePrinter:GetSilencer() < ePrinter:GetMaxSilencer() )
	end,
	[ 8 ] = function( ePrinter )
		return not ePrinter:GetHackNotif()
	end,
	[ 9 ] = function( ePrinter )
		return not ePrinter:GetLowHPNotif()
	end,
}

function ENT:CanUpgrade( iUpgrade )
	if not iUpgrade or not tUpgrade[ iUpgrade ] then
		return false
	end

	return tUpgrade[ iUpgrade ]( self )
end
