--[[

Author: tochnonement
Email: tochnonement@gmail.com

30/07/2024

--]]

onyx:Addon( 'hud', {
    color = Color( 99, 65, 211 ),
    author = 'tochnonement',
    version = '1.1.1',
    licensee = '76561198307194389'
} )

----------------------------------------------------------------

onyx.Include( 'sv_sql.lua' )
onyx.IncludeFolder( 'onyx/modules/hud/languages/' )
onyx.IncludeFolder( 'onyx/modules/hud/core/', true )
onyx.IncludeFolder( 'onyx/modules/hud/cfg/', true )
onyx.IncludeFolder( 'onyx/modules/hud/elements/' )
onyx.IncludeFolder( 'onyx/modules/hud/ui/' )

-- VIP rank sistemi
if CLIENT then
    include('onyx/modules/hud/elements/cl_vip_ranks.lua')
end

onyx.hud:Print( 'Finished loading.' )