
if SERVER then
    AddCSLuaFile("tabdetection/cl_tabdetection.lua")
    AddCSLuaFile("tabdetection/cl_overhead_display.lua")
    include("tabdetection/sv_tabdetection.lua")
else
    include("tabdetection/cl_tabdetection.lua")
    include("tabdetection/cl_overhead_display.lua")
end