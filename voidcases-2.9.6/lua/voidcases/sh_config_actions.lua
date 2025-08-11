local sc = VoidUI.Scale
local L = VoidCases.Lang.GetPhrase

VoidCases.Config = VoidCases.Config or {}
VoidCases.Actions = VoidCases.Actions or {}

/*
    configData.title is the translate phrase
    configData.varType can be: 'string', 'number', 'custom'
    configData.setActive is a function that applies the active value to the input
    configData.customPanel is a function that creates the 'custom' panel
    configData.additionalPanel is a function that creates an additional panel
*/

function VoidCases.CreateAction(name, func, configData)
    VoidCases.Actions[name] = {
        action = func,
        configData = configData
    }
end

hook.Add("InitPostEntity", "VoidCases.Actions.LoadAllActions", function ()
    VoidCases.Load(VoidCases.Dir .. "/custom_actions", true)
end)