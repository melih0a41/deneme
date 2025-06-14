-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local Panel = FindMetaTable('Panel')

function Panel:GetBottomY()
	
	local x,y,w,h = self:GetBounds()
	
	return y+h
	
end

function Panel:GetRightX()
	
	local x,y,w,h = self:GetBounds()
	
	return x+w
	
end