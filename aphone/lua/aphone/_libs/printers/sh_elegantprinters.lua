hook.Add("PostGamemodeLoaded", "APhone_LoadPrinter_ElegantPrinters", function()
    if scripted_ents.Get("sent_elegant_printer") then
        aphone.Printer = aphone.Printer or {}

        function aphone.Printer.GetPrinters(ply)
            local tbl = {}

            for k, v in ipairs(ents.FindByClass("sent_elegant_printer")) do
                if v:CPPIGetOwner() == ply or v:Getowning_ent() == ply then
                    table.insert(tbl, v)
                end
            end

            return tbl
        end

        function aphone.Printer.FormatMoney(amt)
            return DarkRP.formatMoney(amt)
        end

        function aphone.Printer.GetInfo(ents)
            local capacity = 0
            local money = 0
            local sec = 0
            local danger = 0

            for k, v in ipairs(ents) do
                if IsValid(v) then
                    money = money + v:GetMoney()
                    capacity = capacity + v.MaxMoney

                    if v:GetMoney() < v.MaxMoney then
                        sec = sec + v.PrintAmount
                    end

                    danger = danger + (v:GetExploding() and 1 or 0)
                else
                    ents[k] = nil
                end
            end

            return {
                [1] = {
                    val = money,
                    name = "money",
                },

                [2] = {
                    val = sec,
                    name = "sec",
                },

                [3] = {
                    val = capacity,
                    name = "capacity",
                },

                [4] = {
                    val = danger,
                    name = "danger",
                },
            }, ents
        end
    end
end)