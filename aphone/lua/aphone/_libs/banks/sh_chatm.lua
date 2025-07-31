hook.Add("PostGamemodeLoaded", "Aphone_CHATM", function()
    if CH_ATM then
        local p = FindMetaTable("Player")

        if aphone.Bank then
            print("[APhone] Do you got multiples bank addons ? The last loaded bank will be used for the bank app")
        end

        aphone.Bank = aphone.Bank or {}

        aphone.Bank.clr = Color(140, 140, 140)
        aphone.Bank.logo = Material("akulla/aphone/atm.png", "smooth 1")
        aphone.Bank.name = "CH Bank"

        function p:aphone_bankDeposit(amt)
            if amt < 0 or !aphone.Gamemode.Afford(self, amt) then return end
			
			if CH_ATM.GetAccountMaxMoney( self ) != 0 and tonumber( amt + CH_ATM.GetMoneyBankAccount( self ) ) > CH_ATM.GetAccountMaxMoney( self ) then return end
			
            CH_ATM.AddMoneyToBankAccount( self, amt )
            aphone.Gamemode.AddMoney(self, -amt)

            -- Log transaction (only works with SQL enabled)
            CH_ATM.LogSQLTransaction( self, "deposit", amt )
                
            -- bLogs support
            hook.Run( "CH_ATM_bLogs_DepositMoney", self, amt )
        end

        function p:aphone_bankWithdraw(amt)
            if amt < 0 or CH_ATM.GetMoney( self ) - amt < 0 then return end
            aphone.Gamemode.AddMoney(self, amt)
            CH_ATM.TakeMoneyFromBankAccount( self, amt )

            -- Log transaction (only works with SQL enabled)
            CH_ATM.LogSQLTransaction( self, "withdraw", amt )

            -- bLogs support
            hook.Run( "CH_ATM_bLogs_WithdrawMoney", self, amt )
        end

        function p:aphone_bankTransfer(ply2, amt)
            if amt < 0 then return end
            local amtSelfBank = CH_ATM.GetMoney( self )

            if amt > amtSelfBank then return end
            
            CH_ATM.TakeMoneyFromBankAccount( self, amt )
            CH_ATM.AddMoneyToBankAccount( ply2, amt )

            -- Log transaction (only works with SQL enabled)
            CH_ATM.LogSQLTransaction( self, "transfer", amt )
                
            -- bLogs support
            hook.Run( "CH_ATM_bLogs_SendMoney", self, amt, ply2 )
        end

        function p:aphone_getmoney()
            return CH_ATM.GetMoneyBankAccount( self )
        end

        function aphone.Bank.FormatMoney(amt)
            return CH_ATM.FormatMoney(amt)
        end
    end
end)