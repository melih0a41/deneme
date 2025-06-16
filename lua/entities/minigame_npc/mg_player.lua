--[[------------------------------------------------
                Minigame NPC - Player
------------------------------------------------]]--

--[[----------------------------
         Main Functions
----------------------------]]--

function ENT:Kill()
    self:Remove()
end

function ENT:Alive()
    return IsValid(self)
end