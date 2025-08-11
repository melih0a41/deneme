local sc = VoidUI.Scale
local L = VoidCases.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()

    local overlay = self:Add("Panel")
    overlay:Dock(FILL)
    overlay:DockMargin(2,2,2,2)

    local itemsTape = overlay:Add("Panel")
    itemsTape:SetSize(0, 300)


    self.itemsTape = itemsTape
    self.items = {}
    self.models = {}
    self.isSpinning = false
    self.width = sc(700)


    function overlay:PaintOver(w, h)
        local width = 3

        surface.SetDrawColor(VoidUI.Colors.White)
        surface.DrawRect(w/2-width/2, 0, width, h)
    end

end

local function weightedPick(tab)

    math.random()
    math.random()
    math.random()

    local sum = 0

	for _, chance in pairs(tab) do
		sum = sum + chance
	end

	local select = math.random() * sum

	for key, chance in pairs(tab) do
		select = select - chance
		if select < 0 then return key end
	end
    
end

function PANEL:GetRandomItem(possibleItems)
    return VoidCases.Config.Items[tonumber(weightedPick(possibleItems))]
end

function PANEL:Open(case, winningItem)
    self.case = case
    
    local possibleItems = self:GetPossibleItems(case)
    local addAt = math.random(40,80)
    for i = 1, 100 do
        if (addAt == i) then
            self:AddItem(winningItem, true)
        else
            local randomItem = self:GetRandomItem(possibleItems)
            if (!VoidCases.IsItemValid(randomItem)) then continue end
            self:AddItem(randomItem)
        end
    end

    self:StartUnbox(addAt)
end

function PANEL:GetPossibleItems(case)
    return case.info.unboxableItems
end

function PANEL:StartUnbox(winIndex)
    local itemsTape = self.itemsTape
    
    self.isSpinning = true

    local numItem = winIndex
    local pos = 0

    local endPos = ((numItem - 1) * -193) - math.random(25, 100) + self.width/2
    local speed = 0.7
    local finishTime = 1.5
    local finishStartTime = nil
    local finishStartPos = nil
    local endingPosDiff = math.random(30, 50)

    itemsTape.Think = function ()
        if (!self.isSpinning) then return end

        if (!finishStartPos) then
            pos = Lerp(FrameTime() * speed, pos, endPos)
            itemsTape:SetPos(pos, 40)
        end

        local progress = pos / endPos
        if (progress > 0.995) then
            -- lets stop it now
            if (finishStartPos == nil) then 
                finishStartPos = pos
                finishStartTime = CurTime()
            end

            pos = Lerp( (CurTime() - finishStartTime) / finishTime, finishStartPos, endPos)
            itemsTape:SetPos(pos, 40)

            if (progress >= 1) then
                self:FinishSpin()
            end
        end

        
    end
end

function PANEL:FinishSpin()
    self.isSpinning = false
end

function PANEL:AddItem(item, isWinning)
    local itemSize = 190

    local xPos = (self.items[#self.items] or 0)

    local itemPanel = self.itemsTape:Add("VoidCases.Item")
    itemPanel.showMoney = false
    -- itemPanel.d2dunbox = true
    itemPanel:SetSize(itemSize, itemSize)
    itemPanel:SetPos(xPos, 0)

    local isMystery = (self.case.info.mysteryItems and self.case.info.mysteryItems[item.id]) or false
    if (isMystery and !isWinning) then
        local mysteryItemTbl = table.Copy(item)
        mysteryItemTbl.name = L"mystery_item"
        mysteryItemTbl.info.icon = "3Brc7ft"
        itemPanel:SetItem(mysteryItemTbl, true, true)
    else
        itemPanel:SetItem(item)
    end

    self.itemsTape:SetWide(self.itemsTape:GetWide() + 195)

    self.items[#self.items + 1] = xPos + 195

    if (itemPanel.icon.Entity) then
        self.models[#self.models + 1] = itemPanel.icon
    end
end

vgui.Register("VoidCases.CSGOUnbox", PANEL, "Panel")
