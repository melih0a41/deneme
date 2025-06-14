local tex_corner8	= surface.GetTextureID( "gui/corner8" )
local tex_corner16	= surface.GetTextureID( "gui/corner16" )
local tex_corner32	= surface.GetTextureID( "gui/corner32" )
local tex_corner64	= surface.GetTextureID( "gui/corner64" )
local tex_corner512	= surface.GetTextureID( "gui/corner512" )

function CL_ANTICRASH.RoundedTopRect(bordersize, x, y, w, h, color)
	
	if color == nil then return end

	surface.SetDrawColor( color )

	-- Do not waste performance if they don't want rounded corners
	if ( bordersize <= 0 ) then
		surface.DrawRect( x, y, w, h )
		return
	end

	x = math.Round( x )
	y = math.Round( y )
	w = math.Round( w )
	h = math.Round( h )
	bordersize = math.min( math.Round( bordersize ), math.floor( w / 2 ) )

	-- Draw lines between corners
	
	-- Left to right ( top )
	surface.DrawRect( x+bordersize, y, w-bordersize*2, bordersize )
	-- Right to bottom
	surface.DrawRect( x+w-bordersize, y+bordersize, bordersize, h-bordersize )
	-- Left to bottom  
	surface.DrawRect( x, y+bordersize, bordersize, h-bordersize )
	-- Fill gap
	surface.DrawRect( x+bordersize, y, w-bordersize*2, h )

	-- Draw corners
	local tex = tex_corner8
	if ( bordersize > 8 ) then tex = tex_corner16 end
	if ( bordersize > 16 ) then tex = tex_corner32 end
	if ( bordersize > 32 ) then tex = tex_corner64 end
	if ( bordersize > 64 ) then tex = tex_corner512 end

	-- Top corners
	surface.SetTexture( tex )
	surface.DrawTexturedRectUV( x, y, bordersize, bordersize, 0, 0, 1, 1 )
	surface.DrawTexturedRectUV( x + w - bordersize, y, bordersize, bordersize, 1, 0, 0, 1 )

end

function CL_ANTICRASH.RoundedOutlinedRect(bordersize, x, y, w, h, color)
	
	if color == nil then return end

	surface.SetDrawColor( color )

	-- Do not waste performance if they don't want rounded corners
	if ( bordersize <= 0 ) then
		surface.DrawRect( x, y, w, h )
		return
	end

	x = math.Round( x )
	y = math.Round( y )
	w = math.Round( w )
	h = math.Round( h )
	bordersize = math.min( math.Round( bordersize ), math.floor( w / 2 ) )

	-- Draw lines between corners
	
	-- Left to right ( top )
	surface.DrawRect( x+bordersize, y, w-bordersize*2, bordersize )
	-- Left to right ( bottom ) 
	surface.DrawRect( x+bordersize, y+h-bordersize, w-bordersize*2, bordersize )
	-- Right to bottom
	surface.DrawRect( x+w-bordersize, y+bordersize, bordersize, h-bordersize*2 )
	-- Left to bottom  
	surface.DrawRect( x, y+bordersize, bordersize, h-bordersize*2 )

	-- Draw corners
	local tex = tex_corner8
	if ( bordersize > 8 ) then tex = tex_corner16 end
	if ( bordersize > 16 ) then tex = tex_corner32 end
	if ( bordersize > 32 ) then tex = tex_corner64 end
	if ( bordersize > 64 ) then tex = tex_corner512 end

	surface.SetTexture( tex )
	surface.DrawTexturedRectUV( x, y, bordersize, bordersize, 0, 0, 1, 1 )
	surface.DrawTexturedRectUV( x + w - bordersize, y, bordersize, bordersize, 1, 0, 0, 1 )
	surface.DrawTexturedRectUV( x, y + h -bordersize, bordersize, bordersize, 0, 1, 1, 0 )
	surface.DrawTexturedRectUV( x + w - bordersize, y + h - bordersize, bordersize, bordersize, 1, 1, 0, 0 )

end