-- /lua/autorun/server/diamond_vip_final.lua
-- Diamond VIP tek dosya çözüm

local VIP_RANK = "diamondvip"

-- Basit changeTeam override
hook.Add("Initialize", "DiamondVIP_Init", function()
    timer.Simple(10, function() -- DarkRP kesin yüklensin
        local meta = FindMetaTable("Player")
        if not meta then 
            print("[Diamond VIP] HATA: Meta table yok!")
            return 
        end
        
        local oldChangeTeam = meta.changeTeam
        if not oldChangeTeam then 
            print("[Diamond VIP] HATA: changeTeam yok!")
            return 
        end
        
        -- Override
        meta.changeTeam = function(self, team, force, ...)
            -- Konsol debug
            if self:GetUserGroup() == VIP_RANK then
                print("[Diamond VIP] " .. self:Nick() .. " usergroup: " .. self:GetUserGroup() .. " force: " .. tostring(force))
            end
            
            -- Diamond VIP ve force yok
            if self:GetUserGroup() == VIP_RANK and not force then
                print("[Diamond VIP] BYPASS AKTİF! Force=true yapılıyor...")
                
                -- Mesaj
                self:ChatPrint("══════════════════════")
                self:ChatPrint("[Diamond VIP] Limit bypass aktif!")
                self:ChatPrint("══════════════════════")
                
                -- Force et
                return oldChangeTeam(self, team, true, ...)
            end
            
            -- Normal
            return oldChangeTeam(self, team, force, ...)
        end
        
        print("[Diamond VIP] Sistem HAZIR!")
    end)
end)

-- Test komutu
concommand.Add("dvtest", function(ply)
    if not IsValid(ply) then return end
    
    if ply:IsSuperAdmin() then
        ply:SetUserGroup(VIP_RANK)
        ply:ChatPrint("Diamond VIP verildi!")
    end
    
    ply:ChatPrint("Usergroup: " .. ply:GetUserGroup())
    ply:ChatPrint("Diamond VIP: " .. (ply:GetUserGroup() == VIP_RANK and "EVET" or "HAYIR"))
end)

print("[Diamond VIP] Final sistem yüklendi!")