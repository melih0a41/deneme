
AddCSLuaFile()

SWEP.PrintName = "Kelepçe" -- change the name

SWEP.Author = "Brickwall"
SWEP.Instructions = "LMB to handcuff a player. R to inspect. RMB to release."
SWEP.Contact = ""

SWEP.Category = "DarkRP SWEP Replacements" -- change the name

SWEP.DrawCrosshair = false
SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/sterling/c_enchanced_handcuffs.mdl" ) -- just change the model 
SWEP.WorldModel = ( "models/sterling/w_enhanced_handcuffs.mdl" )
SWEP.ViewModelFOV = 85
SWEP.UseHands = true

SWEP.Sound = Sound("weapons/stunstick/stunstick_swing1.wav")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.Base = "weapon_base"

SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetWeaponHoldType( "pistol" )

	self.stickRange = 90
end

function SWEP:SetupDataTables()
    self:NetworkVar( "Int", 0, "CuffTime" )
    self:NetworkVar( "Entity", 0, "Target" )
end

function SWEP:PrimaryAttack()
    if( self:GetCuffTime() > 0 or IsValid( self:GetTarget() ) ) then return end

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )
	timer.Simple( 0.5, function() 
        if( IsValid( self ) and IsValid( self.Weapon ) ) then
            self.Weapon:SendWeaponAnim( ACT_VM_RELOAD ) 
        end
    end )
    self:SetNextPrimaryFire( CurTime() + 0.6 )
    self:SetNextSecondaryFire( CurTime() + 0.6 )

    self:GetOwner():LagCompensation(true)
    local trace = util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * 90, {self:GetOwner()})
    self:GetOwner():LagCompensation(false)

    local ent = trace.Entity
    if IsValid(ent) and ent.onArrestStickUsed then
        ent:onArrestStickUsed(self:GetOwner())
        return
    end

    ent = self:GetOwner():getEyeSightHitEntity(nil, nil, function(p) return p ~= self:GetOwner() and p:IsPlayer() and p:Alive() and p:IsSolid() end)

    local stickRange = self.stickRange * self.stickRange
    if not IsValid(ent) or (self:GetOwner():EyePos():DistToSqr(ent:GetPos()) > stickRange) or not ent:IsPlayer() then
        return
    end

    if( not ent:GetNWBool( "BES_CUFFED", false ) ) then
        local jobTable = RPExtraTeams[ent:Team() or 1] or {}
        if( not table.HasValue( BES.CONFIG.HandCuffs.JobBlacklist, (jobTable.command or "ERROR") ) ) then
            self:SetCuffTime( CurTime()+BES.CONFIG.HandCuffs.CuffTime )
            self:SetTarget( ent )

            if CLIENT then
                self.Dots = ""
                self.NextDotsTime = SysTime() + 0.3
                return
            end
        end
    else
        local canArrest, message = hook.Call("canArrest", DarkRP.hooks, self:GetOwner(), ent)
        if not canArrest then
            if message then DarkRP.notify(self:GetOwner(), 1, 5, message) end
            return
        end
        
        ent:SetWalkSpeed( ent:GetNWInt( "BES_OLDWSPEED", 25 ) )
        ent:SetRunSpeed( ent:GetNWInt( "BES_OLDRSPEED", 100 ) )
        ent:SetNWBool( "BES_CUFFED", false )

        ent:arrest(nil, self:GetOwner())
        DarkRP.notify(ent, 0, 20, DarkRP.getPhrase("youre_arrested_by", self:GetOwner():Nick()))

        if self:GetOwner().SteamName then
            DarkRP.log(self:GetOwner():Nick() .. " (" .. self:GetOwner():SteamID() .. ") arrested " .. ent:Nick(), Color(0, 255, 255))
        end
    end
end

hook.Add( "playerCanChangeTeam", "BES_Hooks_playerCanChangeTeam_Block", function( ply )
    if( ply:GetNWBool( "BES_CUFFED", false ) ) then
        return false, "You cannot change your team while you are cuffed."
    end
end )

hook.Add( "PlayerCanPickupWeapon", "BES_Hooks_PlayerCanPickupWeapon_Block", function( ply, wep )
    if( ply:GetNWBool( "BES_CUFFED", false ) and IsValid( wep ) ) then
        return false
    end
end )

function SWEP:ResetCuffing()
    self:SetTarget( nil )
    self:SetCuffTime( 0 )
end

function SWEP:FinishCuffing()
    self:SetCuffTime( 0 )

    local victim = self:GetTarget()

    self:SetTarget( nil )

    if( IsValid( victim ) ) then
        victim:SetNWBool( "BES_CUFFED", true )
        victim:SetNWInt( "BES_OLDWSPEED", victim:GetWalkSpeed() )
        victim:SetNWInt( "BES_OLDRSPEED", victim:GetRunSpeed() )
        victim:SetWalkSpeed( 25 )
        victim:SetRunSpeed( 25 )

        victim.OldSWEPs = {}
        for k, v in pairs( victim:GetWeapons() ) do
            victim.OldSWEPs[v:GetClass() or ""] = { name = v:GetPrintName() or "", model = v:GetWeaponWorldModel() or "" }
        end

if( SERVER ) then
            -- Oyuncunun silahlarını tek tek kontrol et
            local jobTable = victim:getJobTable() -- Oyuncunun meslek tablosunu al

            for _, wep in ipairs( victim:GetWeapons() ) do
                if IsValid(wep) then
                    local wepClass = wep:GetClass()
                    local isDefault = false
                    local isJobWeapon = false

                    -- Silah varsayılan mı kontrol et
                    if GAMEMODE.Config.DefaultWeapons and table.HasValue( GAMEMODE.Config.DefaultWeapons, wepClass ) then
                        isDefault = true
                    end

                    -- Silah meslek silahı mı kontrol et
                    if jobTable and jobTable.weapons and table.HasValue( jobTable.weapons, wepClass ) then
                        isJobWeapon = true
                    end

                    -- Silah ne varsayılan ne de meslek silahı ise sil
                    if not isDefault and not isJobWeapon then
                         victim:StripWeapon( wepClass )
                    end
                end
            end
        end
    end
end

local dots = {
    [0] = ".",
    [1] = "..",
    [2] = "...",
    [3] = ""
}
function SWEP:Think()
    if( self:GetCuffTime() != 0 and self:GetTarget() and CurTime() >= self:GetCuffTime() ) then
        self:FinishCuffing()
    end

    if( self:GetCuffTime() != 0 and self:GetTarget() ) then
        if( IsValid( self:GetTarget() ) ) then
            self:GetOwner():LagCompensation(true)
            local trace = util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * 90, {self:GetOwner()})
            self:GetOwner():LagCompensation(false)
        
            local ent = trace.Entity
            if( ent != self:GetTarget() ) then
                self:ResetCuffing()
            end
        else
            self:ResetCuffing()
        end

        if CLIENT and (not self.NextDotsTime or SysTime() >= self.NextDotsTime) then
            self.NextDotsTime = SysTime() + 0.3
            self.Dots = self.Dots or ""
            local len = string.len(self.Dots)
    
            self.Dots = dots[len]
        end
    end
end

function SWEP:DrawHUD()
    if( self:GetCuffTime() == 0 or not self:GetTarget() ) then return end

    self.Dots = self.Dots or ""
end

local hookCanUnarrest = {canUnarrest = fp{fn.Id, true}}
function SWEP:SecondaryAttack()
	if CLIENT then return end

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )
	timer.Simple( 0.5, function() 
        if( IsValid( self ) and IsValid( self.Weapon ) ) then
            self.Weapon:SendWeaponAnim( ACT_VM_RELOAD ) 
        end
    end )
    self:SetNextPrimaryFire( CurTime() + 0.6 )
    self:SetNextSecondaryFire( CurTime() + 0.6 )

    self:GetOwner():LagCompensation(true)
    local trace = util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * 90, {self:GetOwner()})
    self:GetOwner():LagCompensation(false)

    local ent = trace.Entity
    if IsValid(ent) and ent.onArrestStickUsed then
        ent:onArrestStickUsed(self:GetOwner())
        return
    end

    ent = self:GetOwner():getEyeSightHitEntity(nil, nil, function(p) return p ~= self:GetOwner() and p:IsPlayer() and p:Alive() and p:IsSolid() end)

    local stickRange = self.stickRange * self.stickRange
    if not IsValid(ent) or (self:GetOwner():EyePos():DistToSqr(ent:GetPos()) > stickRange) or not ent:IsPlayer() then
        return
    end

    if( ent:GetNWBool( "BES_CUFFED", false ) ) then
        ent:SetWalkSpeed( ent:GetNWInt( "BES_OLDWSPEED", 25 ) )
        ent:SetRunSpeed( ent:GetNWInt( "BES_OLDRSPEED", 100 ) )
        ent:SetNWBool( "BES_CUFFED", false )

        if( ent.OldSWEPs ) then
            for k, v in pairs( ent.OldSWEPs ) do
                ent:Give( k )
            end
        end
    else
        local canUnarrest, message = hook.Call("canUnarrest", hookCanUnarrest, self:GetOwner(), ent)
        if not canUnarrest then
            if message then DarkRP.notify(self:GetOwner(), 1, 5, message) end
            return
        end

        ent:unArrest(self:GetOwner())
        DarkRP.notify(ent, 0, 4, DarkRP.getPhrase("youre_unarrested_by", self:GetOwner():Nick()))

        if self:GetOwner().SteamName then
            DarkRP.log(self:GetOwner():Nick() .. " (" .. self:GetOwner():SteamID() .. ") unarrested " .. ent:Nick(), Color(0, 255, 255))
        end
    end
end

function SWEP:Reload()
    if SERVER then return end

    self:GetOwner():LagCompensation(true)
    local trace = util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * 90, {self:GetOwner()})
    self:GetOwner():LagCompensation(false)

    local ent = trace.Entity
    if( IsValid( ent ) and ent:IsPlayer() and ent:GetNWBool( "BES_CUFFED", false ) and not IsValid( BES_CUFF_MENU ) ) then
        BES_CUFF_MENU = vgui.Create( "DFrame" )
        BES_CUFF_MENU:SetSize( ScrW(), ScrH() )
        BES_CUFF_MENU:Center()
        BES_CUFF_MENU:SetTitle( "" )
        BES_CUFF_MENU:SetDraggable( false )
        BES_CUFF_MENU:ShowCloseButton( false )
        BES_CUFF_MENU:MakePopup()
        BES_CUFF_MENU.Paint = function() end

        local MainPanel = vgui.Create( "DPanel", BES_CUFF_MENU )
        MainPanel:SetSize( 400, 450 )
        MainPanel:Center()
        MainPanel.Paint = function( self2, w, h ) 
            surface.SetDrawColor( BES.CONFIG.Themes.Tertiary )
            surface.DrawRect( 0, 0, w, h )
        end

        local TopBar = vgui.Create( "DPanel", MainPanel )
        TopBar:Dock( TOP )
        TopBar:SetTall( 21 )
        TopBar.Paint = function( self2, w, h ) 
            surface.SetDrawColor( BES.CONFIG.Themes.Primary )
            surface.DrawRect( 0, 0, w, h )

            draw.SimpleText( "INSPECTION", "BES_UniSans_15", 5, h/2, Color( 114, 118, 125 ), 0, 1 )
        end

        local CloseButton = vgui.Create( "DButton", TopBar )
        CloseButton:Dock( RIGHT )
        CloseButton:SetWide( 27 )
        CloseButton:SetText( "" )
        local CloseMat = Material( "materials/bricksenchancedsweps/cross.png" )
        local IconSize = 10
        CloseButton.Paint = function( self2, w, h ) 
            if( self2:IsHovered() ) then
                surface.SetDrawColor( BES.CONFIG.Themes.Red )
                surface.DrawRect( 0, 0, w, h )
            end

            surface.SetMaterial( CloseMat )
            if( self2:IsHovered() ) then
                surface.SetDrawColor( 252, 217, 217 )
            else
                surface.SetDrawColor( 154, 156, 159 )
            end
            surface.DrawTexturedRect( (w/2)-(IconSize/2), (h/2)-(IconSize/2), IconSize, IconSize )
        end
        CloseButton.DoClick = function()
            BES_CUFF_MENU:Remove()
        end

        local MaximizeButton = vgui.Create( "DButton", TopBar )
        MaximizeButton:Dock( RIGHT )
        MaximizeButton:SetWide( 27 )
        MaximizeButton:SetText( "" )
        MaximizeButton.Paint = function( self2, w, h ) 
            if( self2:IsHovered() ) then
                surface.SetDrawColor( BES.CONFIG.Themes.Hover )
                surface.DrawRect( 0, 0, w, h )
            end

            if( self2:IsHovered() ) then
                surface.SetDrawColor( 220, 221, 222 )
            else
                surface.SetDrawColor( 185, 187, 190 )
            end
            surface.DrawOutlinedRect( (w/2)-(IconSize/2), (h/2)-(IconSize/2), IconSize, IconSize )
        end
        MaximizeButton.DoClick = function()

        end

        local MinimizeButton = vgui.Create( "DButton", TopBar )
        MinimizeButton:Dock( RIGHT )
        MinimizeButton:SetWide( 27 )
        MinimizeButton:SetText( "" )
        MinimizeButton.Paint = function( self2, w, h ) 
            if( self2:IsHovered() ) then
                surface.SetDrawColor( BES.CONFIG.Themes.Hover )
                surface.DrawRect( 0, 0, w, h )
            end

            if( self2:IsHovered() ) then
                surface.SetDrawColor( 220, 221, 222 )
            else
                surface.SetDrawColor( 185, 187, 190 )
            end
            surface.DrawOutlinedRect( (w/2)-(IconSize/2), (h/2)-(1/2), IconSize, 1 )
        end
        MinimizeButton.DoClick = function()

        end

        local PlayerInfoBack = vgui.Create( "DPanel", MainPanel )
        PlayerInfoBack:Dock( TOP )
        PlayerInfoBack:SetTall( MainPanel:GetTall()*0.2 )
        PlayerInfoBack.Paint = function( self2, w, h ) 
            surface.SetDrawColor( BES.CONFIG.Themes.Secondary )
            surface.DrawRect( 0, 0, w, h )

            draw.SimpleText( ent:Nick() or "NIL", "BES_Calibri_21", h+10, 14, Color( 255, 255, 255 ), 0, 0 )
            draw.SimpleText( (ent:getDarkRPVar( "job" ) or "NIL") .. " - " .. DarkRP.formatMoney( ent:getDarkRPVar( "money" ) or 0 ), "BES_Calibri_19", h+10, 32, BES.CONFIG.Themes.Text, 0, 0 )
        end

        local PlayerInfoAvatar = vgui.Create( "DPanel", PlayerInfoBack )
        PlayerInfoAvatar:Dock( LEFT )
        local Margin = 10
        PlayerInfoAvatar:DockMargin( Margin, Margin, Margin, Margin )
        PlayerInfoAvatar:SetWide( PlayerInfoBack:GetTall()-(2*Margin) )
        PlayerInfoAvatar:TDLib()
        PlayerInfoAvatar:CircleAvatar()
        PlayerInfoAvatar:SetPlayer( ent, 128 )

        local PlayerWeaponsBack = vgui.Create( "DScrollPanel", MainPanel )
        PlayerWeaponsBack:Dock( FILL )
        local Count = 0
        local text = table.Random( BES.FText.Nothing )
        PlayerWeaponsBack.Paint = function( self2, w, h ) 
            if( Count <= 0 ) then
                draw.SimpleText( text, "BES_Calibri_19", w/2, h/2, BES.CONFIG.Themes.Text, 1, 1 )
            end
        end

        local PlayerWeaponsList = vgui.Create( "DIconLayout", PlayerWeaponsBack )
        PlayerWeaponsList:Dock( FILL )

        local Spacing = 5
        for k, v in pairs( ent.OldSWEPs ) do
            if( table.HasValue( GAMEMODE.Config.DefaultWeapons, k ) or GAMEMODE.Config.DisallowDrop[k] or table.HasValue( BES.CONFIG.HandCuffs.Blacklist, k ) ) then continue end

            Count = Count+1

            local WeaponEntry = PlayerWeaponsList:Add( "DPanel" )
            local Size = (MainPanel:GetWide()-Spacing)/4
            WeaponEntry:SetSize( Size, Size )
            WeaponEntry.Paint = function( self2, w, h ) 
                draw.RoundedBox( 8, Spacing, Spacing, w-Spacing, h-Spacing, BES.CONFIG.Themes.Secondary )
    
                draw.SimpleText( v.name or "", "BES_Calibri_16", w/2, h-3, BES.CONFIG.Themes.Text, 1, TEXT_ALIGN_BOTTOM )
            end

            local WeaponEntryIcon = vgui.Create( "DModelPanel", WeaponEntry )
            WeaponEntryIcon:Dock( FILL )
            WeaponEntryIcon:SetModel( v.model )		
            if( IsValid( WeaponEntryIcon.Entity ) ) then
                local mn, mx = WeaponEntryIcon.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
                size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
                size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )

                WeaponEntryIcon:SetFOV( 45 )
                WeaponEntryIcon:SetCamPos( Vector( size, size, size ) )
                WeaponEntryIcon:SetLookAt( ( mn + mx ) * 0.5 )
                function WeaponEntryIcon:LayoutEntity( Entity ) return end
            end

            local WeaponEntryButton = vgui.Create( "DButton", WeaponEntry )
            WeaponEntryButton:Dock( FILL )
            WeaponEntryButton:SetText( "" )
            local yPos = -Size
            local alpha = 0
            local FadeOut = false
            WeaponEntryButton.Paint = function( self2, w, h ) 
                if( self2:IsHovered() and not FadeOut ) then
                    yPos = math.Clamp( yPos+8, -h, Spacing )
                    alpha = math.Clamp( alpha+8, 100, 255 )
                elseif( not FadeOut ) then
                    yPos = math.Clamp( yPos-8, -h, Spacing )
                    alpha = math.Clamp( alpha-8, 100, 255 )
                else
                    alpha = math.Clamp( alpha-12, 0, 255 )
                end

                if( yPos > -h ) then
                    surface.SetAlphaMultiplier( alpha/255 )
                    draw.RoundedBox( 8, Spacing, yPos, w-Spacing, h-Spacing, BES.CONFIG.Themes.Primary )

                    if( self2:IsDown() ) then
                        surface.SetAlphaMultiplier( 0.25 )
                        draw.RoundedBox( 8, Spacing, yPos, w-Spacing, h-Spacing, BES.CONFIG.Themes.Secondary )
                        surface.SetAlphaMultiplier( 1 )
                    end

                    draw.SimpleText( "CONFISCATE", "BES_Calibri_16", Spacing+((w-Spacing)/2), yPos+((h-Spacing)/2), BES.CONFIG.Themes.Text, 1, 1 )
                    surface.SetAlphaMultiplier( 1 )
                end
            end
            WeaponEntryButton.DoClick = function()
                FadeOut = true
                WeaponEntry:AlphaTo( 0, 0.25, 0, function()
                    if( IsValid( WeaponEntry ) ) then
                        WeaponEntry:Remove()
                        Count = Count-1
                    end
                end )

                if( IsValid( ent ) and k ) then
                    net.Start( "BES_Net_Confiscate" )
                        net.WriteEntity( ent )
                        net.WriteString( k or "" )
                    net.SendToServer()
                end
            end
        end
    end
end

if( SERVER ) then
    util.AddNetworkString( "BES_Net_Confiscate" )
    net.Receive( "BES_Net_Confiscate", function( len, ply )
        local Victim = net.ReadEntity()
        local WepClass = net.ReadString()

        if( not Victim or not WepClass or not IsValid( Victim ) ) then return end
        if( not Victim:GetNWBool( "BES_CUFFED", false ) or not IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon():GetClass() == "dsr_handcuffs" ) then return end
        if( ply:GetPos():DistToSqr( Victim:GetPos() ) > 10000 ) then return end

        if( table.HasValue( GAMEMODE.Config.DefaultWeapons, WepClass ) or GAMEMODE.Config.DisallowDrop[WepClass] ) then return end

        if( Victim.OldSWEPs and Victim.OldSWEPs[WepClass] ) then
            Victim.OldSWEPs[WepClass] = nil
        end
    end )
end

if( CLIENT ) then
    hook.Add( "HUDPaint", "BESHooks_HUDPaint_DrawCuffed", function()
        if( IsValid( LocalPlayer():GetActiveWeapon() ) and LocalPlayer():GetActiveWeapon():GetClass() == "dsr_handcuffs" ) then
            local self = LocalPlayer():GetActiveWeapon()
            if( self:GetCuffTime() != 0 and self:GetTarget() ) then
                local status = math.Clamp( 1-(self:GetCuffTime()-CurTime())/BES.CONFIG.HandCuffs.CuffTime, 0, 1)
                local Spacing = 0
                local Thickness = 7
                local Radius = 65
				
                draw.Arc( ScrW()/2, ScrH()/2, Radius, Thickness, 0, 360, 3, Color( 35, 38, 45 ) )
                draw.Arc( ScrW()/2, ScrH()/2, Radius-Spacing, Thickness-(2*Spacing), 0, (status*360), 3, HSVToColor( 90*status, 1, 1 ) )
                draw.Arc( ScrW()/2, ScrH()/2, Radius-Spacing, Thickness-(2*Spacing), 0, 360, 3, Color( 50, 50, 50, 100 ) )

                draw.DrawNonParsedSimpleText( "Cuffing", "BES_Myriad_24", ScrW()/2, ScrH()/2, Color(255, 255, 255, 255), 1, 1)
            end

            if( BES.CONFIG.HandCuffs.ShowHint ) then
                draw.SimpleText( "LMB to arrest, R to inspect", "BES_Calibri_19", ScrW()/2, ScrH()-25, BES.CONFIG.Themes.Text, 1, TEXT_ALIGN_BOTTOM )
            end
            
            for k, v in pairs( ents.FindInSphere( LocalPlayer():GetPos(), 300 ) ) do
                if( not IsValid( v ) or not v:IsPlayer() or not v:GetNWBool( "BES_CUFFED", false ) ) then continue end

                local Distance = LocalPlayer():GetPos():DistToSqr( v:GetPos() )

                local AlphaMulti = 1-(Distance/(300*300))
        
                if( Distance < (300*300) ) then
                    local zOffset = v:OBBMaxs().z/2
                    local Pos = v:GetPos()
                    local x = Pos.x
                    local y = Pos.y
                    local z = Pos.z
                    local pos = Vector(x,y,z+zOffset)
                    local pos2d = pos:ToScreen()
        
                    surface.SetAlphaMultiplier( AlphaMulti )
                        draw.SimpleText( "CUFFED", "BES_Myriad_38", pos2d.x, pos2d.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                    surface.SetAlphaMultiplier( 1 )
                end
            end
        end
    end )
end

if( SERVER ) then
	hook.Add( "PlayerDeath", "BESHooks_PlayerDeath_StopCuffed", function( victim )
		if( victim:GetNWBool( "BES_CUFFED", false ) ) then
			victim:SetWalkSpeed( victim:GetNWInt( "BES_OLDWSPEED", 25 ) )
			victim:SetRunSpeed( victim:GetNWInt( "BES_OLDRSPEED", 100 ) )
			victim:SetNWBool( "BES_CUFFED", false )
		end
	end )
end