local Reward = {}

Reward.Name = "SAdmin Group"

Reward.MaxAmount = 44640

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	if amount > 1 then
		sAdmin.setRank(ply, key, amount, "user")
	else
		sAdmin.setRank(ply, key)
	end
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 4 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key, parent)
	local mW, mH = parent:GetWide(), parent:GetTall()
	local textPanel = vgui.Create( "DPanel" , parent )
    textPanel:SetPos( mW*0.10, mH*0.10 )
	textPanel:SetSize( mW*0.80, mH*0.80 )
    textPanel.Paint = function(self, w, h)
    	draw.SimpleText( key or "", "ADRewards_5",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end
    return textPanel
end

Reward.DrawKey = "UserGroup"

Reward.GetKey = function(name)
	local key = sAdmin.usergroups[name] and name or nil
	return key
end

Reward.LangPhrase = "SAdmin_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the usergroup name. Example: «vip». Number means the time in minutes for which the user will receive the privilege. (Must be greater than 1)"
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву групи користувачів. Наприклад: «vip». Кількість означає час у хвилинах на який користувач отримає привілей. (Повинно бути більше 1)"
ADRLang.ru[Reward.LangPhrase] = "Используйте имя группы пользователей. Например: «vip». Количество означает время в минутах на которое пользователь получит привилегию. (Должно быть больше 1)"
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom du groupe d'utilisateurs. Exemple : «vip». Le nombre indique la durée en minutes pendant laquelle l'utilisateur recevra le privilège. (Doit être supérieur à 1)"
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen der Benutzergruppe. Beispiel: «vip». Die Zahl gibt die Zeit in Minuten an, für die der Benutzer die Berechtigung erhält. (Muss größer als 1 sein)"
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy grupy użytkowników. Przykład: «vip». Liczba oznacza czas w minutach, na jaki użytkownik otrzyma przywilej. (Musi być większa niż 1)"
ADRLang.tr[Reward.LangPhrase] = "Kullanıcı grubu adını kullanın. Örnek: «vip». Sayı, kullanıcının ayrıcalığı alacağı dakika cinsinden süre anlamına gelir. (1'den büyük olmalıdır)"
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice el nombre del grupo de usuarios. Ejemplo: «vip». El número indica el tiempo en minutos durante el cual el usuario recibirá el privilegio. (Debe ser mayor que 1)"
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if sAdmin then return true end
	return false
end


ADRewards.CreateReward(Reward)