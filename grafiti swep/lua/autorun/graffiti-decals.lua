local colors = {'black', 'white', 'silver', 'asphalt', 'shadow', 'graphite', 'fir', 'emerald', 'mint', 'ocean', 'sky', 'linen', 'corn', 'gold', 'lemon', 'barberry', 'biscuit', 'skin', 'coral', 'assol', 'orange', 'lavender', 'lilac', 'plum'}
local brush = {'nothing', 'amogus', 'floppa', 'shrek'}

for i=1, 4 do
    game.AddDecal(brush[i], 'brush/' .. brush[i])
end

for i=1, 24 do
    game.AddDecal(colors[i] .. '-s', 'effects/small/' .. colors[i] .. '-s')
    game.AddDecal(colors[i] .. '-n', 'effects/normal/' .. colors[i] .. '-n')
    game.AddDecal(colors[i] .. '-l', 'effects/large/' .. colors[i] .. '-l')
end