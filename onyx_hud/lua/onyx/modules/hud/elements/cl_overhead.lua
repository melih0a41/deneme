--[[

Author: tochnonement
Email: tochnonement@gmail.com

11/08/2024

--]]

local hud = onyx.hud
local nearest = {}
local statuses = {}

local MAX_DISTANCE = 400 ^ 2
local MAX_GLOBAL_DRAWS = 12

local CONVAR_MAX_DETAILED = CreateClientConVar( 'cl_onyx_hud_3d2d_max_details', '3', true, false, '', 1, 5 )

local COLOR_LOW_HP = Color( 255, 59, 59)
local COLOR_MAX_HP = Color( 115, 255, 49)
local COLOR_ARMOR = Color( 52, 130, 255)
local COLOR_RED = Color( 255, 52, 52)
local COLOR_BLUE = Color( 55, 52, 255)
local COLOR_SLIGHT_SHADOW = Color( 0, 0, 0, 150 )
local ICON_SIZE = 64
local WIMG_LICENSE = onyx.wimg.Create( 'hud_license', 'smooth mips' )

local FONT_NAME = onyx.hud.CreateFont3D2D( 'OverheadName', 'Comfortaa Bold', 72 )
local FONT_JOB = onyx.hud.CreateFont3D2D( 'OverheadJob', 'Comfortaa SemiBold', 40 )
local FONT_STATUS = onyx.hud.CreateFont3D2D( 'OverheadStatus', 'Comfortaa Bold', 64 )

local drawShadowText = onyx.hud.DrawShadowText

local getStatuses, hasStatus do
    local function createStatus( data )
        data.wimg = onyx.wimg.Create( data.icon, 'smooth mips' )
        table.insert( statuses, data )
    end

    function getStatuses( ply )
        local result = {}
        for _, status in ipairs( statuses ) do
            if ( status.func( ply ) ) then
                table.insert( result, status )
            end
        end
        return result
    end

    -- Quicker than checking by amount
    function hasStatus( ply )
        for _, status in ipairs( statuses ) do
            if ( status.func( ply ) ) then
                return true
            end
        end
        return false
    end

    createStatus( {
        id = 'wanted',
        icon = 'hud_wanted',
        big = true,
        func = function( ply )
            return ply:getDarkRPVar( 'wanted' )
        end,
        getColor = function()
            local fraction = math.abs( math.sin( CurTime() ) )
            local color = onyx.LerpColor( fraction, COLOR_RED, COLOR_BLUE )
            return color
        end
    } )

    createStatus( {
        id = 'speaking',
        icon = 'hud_microphone',
        func = function( ply )
            return ply:IsSpeaking()
        end
    } )

    createStatus( {
        id = 'typing',
        icon = 'hud_chat',
        func = function( ply )
            return ply:IsTyping()
        end
    } )
end

local function drawStatus( ply, y )
    local halfIconSize = ICON_SIZE * .5
    local iconSpace = 10
    local statuses = getStatuses( ply )
    local amount = #statuses
    local totalW = amount * ICON_SIZE + ( amount - 1 ) * iconSpace
    local iconX = -totalW * .5
    local isSingle = amount == 1

    -- Draw microphone
    for i = 1, amount do
        local status = statuses[ i ]
        local color = status.getColor and status.getColor() or ( status.color or hud:GetColor( 'accent' ) )

        if ( isSingle and status.big ) then
            status.text = status.text or onyx.lang:Get( 'hud_status_' .. status.id )
            local text = status.text

            if ( status.dots ) then
                text = text .. string.rep( '.', CurTime() % 4 )
            end
        
            surface.SetFont( FONT_STATUS )
            local textW, textH = surface.GetTextSize( text )
            
            iconX = iconX - ( textW + iconSpace ) * .5

            drawShadowText( text, FONT_STATUS, iconX + ICON_SIZE + iconSpace, y + ICON_SIZE * .5 - textH * .5, color )
        end

        status.wimg:Draw( iconX + 2, y + 2, ICON_SIZE, ICON_SIZE, COLOR_SLIGHT_SHADOW )
        status.wimg:Draw( iconX, y, ICON_SIZE, ICON_SIZE, color )
    
        iconX = iconX + ICON_SIZE + iconSpace
    end
end

local function drawQuickInfo( ply, client )
    drawStatus( ply, 0 )
end

local function drawInfo( ply, client )
    local playerName = ply:Name()
    local teamID = ply:Team()
    local teamName = team.GetName( teamID )
    local teamColor = team.GetColor( teamID )
    local hasLicense = ply:getDarkRPVar( 'HasGunlicense' )
    local shouldDrawHealth = hud.IsElementEnabled( 'overhead_health' )
    
    -- VIP rank kontrolü
    local vipRank, vipData = onyx.hud.GetPlayerVIPRank(ply)

    local currentY = 0

    drawStatus( ply, -ICON_SIZE )

    -- Draw name with VIP badge
    surface.SetFont( FONT_NAME )
    local nameTextW, nameTextH = surface.GetTextSize( playerName )
    
    -- VIP badge genişliğini hesapla - İSMİN SOLUNDA OLACAK
    local vipBadgeWidth = 0
    local vipSpacing = 15 -- VIP ile isim arası boşluk
    
    if vipData then
        surface.SetFont( FONT_NAME ) -- İsimle aynı font
        local vipW = surface.GetTextSize(vipData.short)
        vipBadgeWidth = vipW + vipSpacing
    end
    
    local totalWidth = vipBadgeWidth + nameTextW + (hasLicense and 47 or 0)
    
    if ( hasLicense or vipData ) then
        local iconSize = 32
        local iconSpace = 15
        
        local startX = -totalWidth * 0.5
        
        -- VIP badge'i SOL TARAFTA çiz
        if vipData then
            -- VIP metninin etrafına renkli çerçeve çiz
            surface.SetFont( FONT_NAME )
            local vipTextW, vipTextH = surface.GetTextSize(vipData.short)
            
            -- Çerçeve padding
            local framePadding = 10
            local frameX = startX
            local frameY = currentY - framePadding  -- Sadece üst padding kadar yukarı
            local frameW = vipTextW + framePadding * 2
            local frameH = vipTextH + framePadding * 2
            
            -- Gölge efekti
            draw.RoundedBox(6, frameX + 2, frameY + 2, frameW, frameH, COLOR_SLIGHT_SHADOW)
            
            -- Ana arka plan - VIP rengine göre hafif renkli
            local bgColor = Color(
                20 + vipData.color.r * 0.15,  -- VIP renginin %15'i
                20 + vipData.color.g * 0.15,
                20 + vipData.color.b * 0.15,
                220  -- Yüksek opaklık
            )
            draw.RoundedBox(6, frameX, frameY, frameW, frameH, bgColor)
            
            -- İç ışıma efekti (gradient benzeri)
            local glowColor = Color(vipData.color.r, vipData.color.g, vipData.color.b, 30)
            draw.RoundedBox(6, frameX + 2, frameY + 2, frameW - 4, frameH - 4, glowColor)
            
            -- Renkli çerçeve (2 piksel kalınlıkta)
            surface.SetDrawColor(vipData.color)
            for i = 0, 1 do
                surface.DrawOutlinedRect(frameX + i, frameY + i, frameW - i*2, frameH - i*2, 1)
            end
            
            -- Köşelere küçük süslemeler
            local cornerSize = 4
            surface.SetDrawColor(vipData.color)
            -- Sol üst
            surface.DrawRect(frameX - 1, frameY - 1, cornerSize, 2)
            surface.DrawRect(frameX - 1, frameY - 1, 2, cornerSize)
            -- Sağ üst
            surface.DrawRect(frameX + frameW - cornerSize + 1, frameY - 1, cornerSize, 2)
            surface.DrawRect(frameX + frameW - 1, frameY - 1, 2, cornerSize)
            -- Sol alt
            surface.DrawRect(frameX - 1, frameY + frameH - 1, cornerSize, 2)
            surface.DrawRect(frameX - 1, frameY + frameH - cornerSize + 1, 2, cornerSize)
            -- Sağ alt
            surface.DrawRect(frameX + frameW - cornerSize + 1, frameY + frameH - 1, cornerSize, 2)
            surface.DrawRect(frameX + frameW - 1, frameY + frameH - cornerSize + 1, 2, cornerSize)
            
            -- VIP metni - Baş harf kalın ve sola kaydırılmış
            local firstLetter = string.sub(vipData.short, 1, 1)  -- İlk harf (D, S, G, P, B)
            local restText = string.sub(vipData.short, 2)        -- Geri kalan (VIP)
            
            -- İlk harfin genişliğini hesapla
            surface.SetFont( FONT_NAME )
            local firstLetterW = surface.GetTextSize(firstLetter)
            local restTextW = surface.GetTextSize(restText)
            
            -- Harfler arası boşluk
            local letterSpacing = 5
            
            -- Toplam metin genişliği
            local totalTextW = firstLetterW + letterSpacing + restTextW
            
            -- Başlangıç pozisyonu (ortalanmış)
            local textStartX = frameX + frameW/2 - totalTextW/2
            local textY = frameY + frameH/2 - vipTextH/2
            
            -- İlk harf için daha parlak renk
            local brightColor = Color(
                math.min(255, vipData.color.r + 60),
                math.min(255, vipData.color.g + 60),
                math.min(255, vipData.color.b + 60),
                255
            )
            
            -- İlk harf - Çok kalın ve parlak
            -- Daha fazla katman için çiz
            for offsetX = -2, 2 do
                for offsetY = -2, 2 do
                    if math.abs(offsetX) == 2 or math.abs(offsetY) == 2 then
                        -- Dış glow efekti
                        surface.SetFont( FONT_NAME )
                        surface.SetTextColor( vipData.color.r, vipData.color.g, vipData.color.b, 50 )
                        surface.SetTextPos( textStartX + offsetX, textY + offsetY )
                        surface.DrawText( firstLetter )
                    elseif offsetX ~= 0 or offsetY ~= 0 then
                        -- İç kalınlık
                        surface.SetFont( FONT_NAME )
                        surface.SetTextColor( brightColor.r, brightColor.g, brightColor.b, 150 )
                        surface.SetTextPos( textStartX + offsetX, textY + offsetY )
                        surface.DrawText( firstLetter )
                    end
                end
            end
            
            -- Gölge efekti
            surface.SetFont( FONT_NAME )
            surface.SetTextColor( 0, 0, 0, 255 )
            surface.SetTextPos( textStartX + 2, textY + 2 )
            surface.DrawText( firstLetter )
            
            -- Ana ilk harf - En parlak
            surface.SetFont( FONT_NAME )
            surface.SetTextColor( brightColor.r, brightColor.g, brightColor.b, 255 )
            surface.SetTextPos( textStartX, textY )
            surface.DrawText( firstLetter )
            
            -- Geri kalan "VIP" kısmı - sağa kaydırılmış
            local vipX = textStartX + firstLetterW + letterSpacing
            
            -- Gölge
            surface.SetFont( FONT_NAME .. ".Blur" )
            surface.SetTextColor( 0, 0, 0, 255 )
            surface.SetTextPos( vipX + 2, textY + 2 )
            surface.DrawText( restText )
            
            -- Ana metin
            surface.SetFont( FONT_NAME )
            surface.SetTextColor( vipData.color.r, vipData.color.g, vipData.color.b, vipData.color.a )
            surface.SetTextPos( vipX, textY )
            surface.DrawText( restText )
            
            startX = frameX + frameW + vipSpacing
        end
        
        -- İsmi çiz
        drawShadowText( playerName, FONT_NAME, startX, currentY, color_white )
        
        -- Lisans ikonunu çiz
        if hasLicense then
            local licenseX = startX + nameTextW + iconSpace
            local iconY = currentY + nameTextH * .5 - iconSize * .5
            
            WIMG_LICENSE:Draw( licenseX + 2, iconY + 2, iconSize, iconSize, COLOR_SLIGHT_SHADOW )
            WIMG_LICENSE:Draw( licenseX, iconY, iconSize, iconSize )
        end
        
        currentY = currentY + 65
    else
        drawShadowText( playerName, FONT_NAME, 0, currentY, color_white, 1, 0 )
        currentY = currentY + 65
    end

    -- Draw team
    drawShadowText( teamName, FONT_JOB, 0, currentY + 10, teamColor, 1, 0 )
    currentY = currentY + 50

    -- Draw health & armor
    if ( shouldDrawHealth ) then
        local healthInt = ply:Health()
        local healthFraction = math.Clamp( healthInt / ply:GetMaxHealth(), 0, 1 )
        local healthColor = onyx.LerpColor( healthFraction, COLOR_LOW_HP, COLOR_MAX_HP )
        
        local armorInt = ply:Armor()
        local shouldDrawArmor = armorInt > 0 and hud.IsElementEnabled( 'overhead_armor' )

        local healthText = healthInt .. ' HP'
        
        if ( shouldDrawArmor ) then
            healthText = healthText .. '  '
            local armorText = armorInt .. ' AP'

            surface.SetFont( FONT_JOB )
            local healthTextWidth = surface.GetTextSize( healthText )
            local armorTextWidth = surface.GetTextSize( armorText )
            local totalTextWidth = healthTextWidth + armorTextWidth
            local textX = -totalTextWidth * .5
        
            drawShadowText( healthText, FONT_JOB, textX, currentY, healthColor )
            drawShadowText( armorText, FONT_JOB, textX + healthTextWidth, currentY, COLOR_ARMOR )
        else
            drawShadowText( healthText, FONT_JOB, 0, currentY, healthColor, 1, 0 )
        end

        currentY = currentY + 30
    end
end

timer.Create( 'onyx.hud.CollectNearestPlayers', 1 / 10, 0, function()
    local client = LocalPlayer()
    if ( IsValid( client ) ) then
        nearest = {}

        -- Make sure that any random error (if there is any) won't break the timer
        ProtectedCall( function()
            local origin = client:GetPos()
            local aimVector = client:GetAimVector()
        
            for _, ply in ipairs( player.GetAll() ) do
                local playerPos = ply:GetPos()
                if ( ply ~= client and ply:Alive() and ply:GetColor().a > 50 and ply:Health() > 0 and not ply:GetNoDraw() and ply:GetRenderMode() ~= RENDERMODE_NONE and playerPos:DistToSqr( origin ) <= MAX_DISTANCE ) then
                    local dotProduct = aimVector:Dot( ( playerPos - origin ):GetNormalized() )
                    if ( dotProduct > .6 ) then
                        table.insert( nearest, {
                            ply = ply,
                            dot = dotProduct
                        } )
                    end
                end
            end

            table.sort( nearest, function( a, b )
                return a.dot > b.dot
            end )
        end )
    end
end )

hook.Add( 'PostDrawTranslucentRenderables', 'onyx.hud.DrawOverheadInfo', function()
    local client = LocalPlayer()
    local index = 0

    for _, object in ipairs( nearest ) do
        local ply = object.ply
        if ( IsValid( ply ) ) then
            index = index + 1
            if ( index > MAX_GLOBAL_DRAWS ) then break end

            local detailed = index <= CONVAR_MAX_DETAILED:GetInt()
            local shouldDraw = detailed or hasStatus( ply )

            if ( shouldDraw ) then
                local _, maxs = ply:GetRenderBounds()
                local jobTable = ply:getJobTable() or {}
                local heightOffset = jobTable.onyxOverheadOffset or ( maxs.z + 10 )
                local pos = ply:GetPos() + Vector( 0, 0, heightOffset )
                local ang = Angle( 0, client:EyeAngles().y - 90, 90 )
                
                cam.Start3D2D( pos, ang, 0.075 )
                    if ( detailed ) then
                        drawInfo( ply, client )
                    else
                        drawQuickInfo( ply, client )
                    end
                cam.End3D2D()
            end
        end
    end
end )