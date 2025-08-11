
VoidCases.Inventory = VoidCases.Inventory or {}
VoidCases.Marketplace = VoidCases.Marketplace or {}
VoidCases.Equipped = VoidCases.Equipped or {}

hook.Add("HUDPaint", "VoidCases.RequestInventoryData", function ()

    VoidCases.PrintDebug("Requesting inventory data")
    
    net.Start("VoidCases_RequestInventory")
    net.SendToServer()

    VoidCases.RequestConfigData()

    hook.Remove("HUDPaint", "VoidCases.RequestInventoryData")
end)

local function netReceiveEquipped()
    VoidCases.Equipped = net.ReadTable()

    VoidCases.PrintDebug("Received equipped data!")
end
net.Receive("VoidCases_NetworkEquipped", netReceiveEquipped)

local function netReceiveOneEquip()
    local item = net.ReadUInt(32)
    local bool = net.ReadBool()

    VoidCases.Equipped[item] = bool
end
net.Receive("VoidCases_NetworkEquippedOne", netReceiveOneEquip)

local function netReceiveInventory()
    VoidCases.Inventory = net.ReadTable()

    VoidCases.PrintDebug("Received inventory data!")
end
net.Receive("VoidCases_NetworkInventory", netReceiveInventory)

local function netReceiveMarketplace()
    local len = net.ReadUInt(32)
    local data = net.ReadData(len)

    data = util.Decompress(data)
    data = util.JSONToTable(data)

    if (!data) then
        data = {}
    end

    VoidCases.Marketplace = data

    if (!IsValid(VoidCases.Menu)) then return end
    VoidCases.Menu.refreshMarketplace()

    VoidCases.PrintDebug("Received marketplace data!")
end
net.Receive("VoidCases_NetworkMarketplace", netReceiveMarketplace)

local function netReceiveItem()
    local item = net.ReadUInt(32)
    local amount = net.ReadInt(32)

    local invItem = VoidCases.Inventory[item]
    if (invItem) then
        VoidCases.Inventory[item] = invItem + amount
    else
        VoidCases.Inventory[item] = amount
    end

    VoidCases.PrintDebug("Received inventory item " .. item)

    if (!IsValid(VoidCases.Menu)) then return end
    VoidCases.Menu.refreshItems()
    
end
net.Receive("VoidCases_NetworkItem", netReceiveItem)

local function netReceiveFeaturedItems()
    local len = net.ReadUInt(32)
    local data = net.ReadData(len)

    data = util.Decompress(data)
    data = util.JSONToTable(data)

    if (!data) then
        data = {}
    end

    VoidCases.Config.FeaturedItems = data
    VoidCases.PrintDebug("Received featured items data!")
end
net.Receive("VoidCases_NetworkFeaturedItems", netReceiveFeaturedItems)