-- [[ CREATED BY ZOMBIE EXTINGUISHER]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local graphOffset = 10

function PANEL:Init(realInit, hideButtons)

	if !realInit then return end
	
	local pWide, pTall = self:GetSize()
	local graphW, graphH = pWide-(graphOffset*2), pTall*0.4
	
	-- Graph
	local graphPanel = CL_ANTICRASH.CreateGraph(graphOffset, graphOffset, graphW, graphH, self)
	
	-- Graph Information
	local infoMarginW, infoMarginH  = 10, 10
	local infoW, infoH = graphW/2-(infoMarginW/2), pTall*0.05 
	local categoryOffset = 26
	
	local lagInfo = CL_ANTICRASH.CreateGraphInfoLabel(graphOffset, graphPanel:GetBottomY()+categoryOffset, infoW, infoH, SH_ANTICRASH.Translate("lag"), "ZLAG", false, self, true)
	local collisionInfo = CL_ANTICRASH.CreateGraphInfoLabel(lagInfo:GetRightX()+infoMarginW, graphPanel:GetBottomY()+categoryOffset, infoW, infoH, SH_ANTICRASH.Translate("collisions"), "COLLISIONS",true, self, true)
	
	local propInfo = CL_ANTICRASH.CreateGraphInfoLabel(graphOffset, collisionInfo:GetBottomY()+infoMarginH, infoW, infoH, SH_ANTICRASH.Translate("props"), "PROPS", true, self, true)
	local frozenInfo = CL_ANTICRASH.CreateGraphInfoLabel(propInfo:GetRightX()+infoMarginW, collisionInfo:GetBottomY()+infoMarginH, infoW, infoH, SH_ANTICRASH.Translate("propsFrozen"), "FROZENPROPS", true, self, true)
	
	local npcInfo = CL_ANTICRASH.CreateGraphInfoLabel(graphOffset, frozenInfo:GetBottomY()+infoMarginH, infoW, infoH, SH_ANTICRASH.Translate("npcs"), "NPCS",true, self, true)
	local vehicleInfo = CL_ANTICRASH.CreateGraphInfoLabel(npcInfo:GetRightX()+infoMarginW, frozenInfo:GetBottomY()+infoMarginH, infoW, infoH, SH_ANTICRASH.Translate("vehicles"), "VEHICLES", true, self, true)
	
	-- Extra Information
	local playerInfo = CL_ANTICRASH.CreateGraphInfoLabel(graphOffset, vehicleInfo:GetBottomY()+categoryOffset, infoW, infoH, SH_ANTICRASH.Translate("players"), "PLAYERS",true, self)
	local uptimeInfo = CL_ANTICRASH.CreateGraphInfoLabel(playerInfo:GetRightX()+infoMarginW, vehicleInfo:GetBottomY()+categoryOffset, infoW, infoH, SH_ANTICRASH.Translate("uptime"), "UPTIME",true, self) 
	
	local entityInfo = CL_ANTICRASH.CreateGraphInfoLabel(graphOffset, playerInfo:GetBottomY()+infoMarginH, infoW, infoH, SH_ANTICRASH.Translate("entities"), "ENTITIES", true, self)
	local spawnedInfo = CL_ANTICRASH.CreateGraphInfoLabel(entityInfo:GetRightX()+infoMarginW, playerInfo:GetBottomY()+infoMarginH, infoW, infoH, SH_ANTICRASH.Translate("spawned"), "SPAWNED", true, self)
	
	local fpsInfo = CL_ANTICRASH.CreateGraphInfoLabel(graphOffset, entityInfo:GetBottomY()+infoMarginH, infoW, infoH, SH_ANTICRASH.Translate("fps"), "FPS",true, self)
	local tickrateInfo = CL_ANTICRASH.CreateGraphInfoLabel(fpsInfo:GetRightX()+infoMarginW, entityInfo:GetBottomY()+infoMarginH, infoW, infoH, SH_ANTICRASH.Translate("tickrate"), "TICKRATE", true, self)
	
	if !hideButtons then
	
		-- Open stats overlay
		CL_ANTICRASH.CreateButtonColorFade(graphOffset, pTall-categoryOffset-53, graphW, infoH, SH_ANTICRASH.Translate("toggleOverlay"), "z_anticrash_graph_btn", SH_ANTICRASH.VARS.COLOR.GREY, color_white, self, function()
			CL_ANTICRASH.PlaySound("togglePress")
			RunConsoleCommand("anticrash_overlay_open")
		end)
	
		-- Run anti-lag measures
		CL_ANTICRASH.CreateButtonColorFade(graphOffset, pTall-categoryOffset-13, graphW, infoH, SH_ANTICRASH.Translate("runAntiLagMeasures"), "z_anticrash_graph_btn", SH_ANTICRASH.VARS.COLOR.BLUE, color_white, self, function()
			CL_ANTICRASH.PlaySound("runAntiLag")
			net.Start( "sv_anticrash_TriggerAntiLagMeasures" )
			net.SendToServer()
		end)
	
	end
	
end
vgui.Register('p_anticrash_stats',PANEL,'DScrollPanel')