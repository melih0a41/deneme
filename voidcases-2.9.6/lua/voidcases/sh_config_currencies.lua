VoidCases.Config = VoidCases.Config or {}
VoidCases.Currencies = VoidCases.Currencies or {}

function VoidCases.AddCurrency(name, getFunc, addFunc)
    VoidCases.Currencies[name] = {
        getFunc = getFunc,
        addFunc = addFunc,
    }
end

hook.Add("InitPostEntity", "VoidCases.Currencies.LoadAllCurrencies", function ()
    VoidCases.Load(VoidCases.Dir .. "/custom_currencies", true)
end)