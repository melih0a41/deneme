-- [[ CREATED BY ZOMBIE EXTINGUISHER]]

local translationFiles = file.Find( "z_anticrash/languages/*.lua", "LUA" )
local translations = {}
local languages = {}
local langConvarName = "gmod_language"
 
-- intialize languages  
for _,translation in pairs(translationFiles) do

	local f = "z_anticrash/languages/"..translation

	if SERVER then
		AddCSLuaFile(f)
	end
	
	-- get the lang code from file name
	local langCode = string.match(translation,"(%a+).lua")
	langCode = langCode:upper()
	
	-- add the code to the range of languages
	table.insert(languages,langCode)
 
	-- store the translations in the var
	translations[langCode] = include( f )
	
end

function SH_ANTICRASH.GetLanguages()
	return languages
end

function SH_ANTICRASH.GetLanguage()

	if SERVER then
		return SH_ANTICRASH.SETTINGS.SYSTEMLANG
	end
	
	langConvar = GetConVar( langConvarName )
	return langConvar:GetString():upper()
	
end

function SH_ANTICRASH.Translate(str)

	local playerLang = SH_ANTICRASH.GetLanguage()
	local translatedStr = (translations[playerLang] and translations[playerLang][str]) or translations["EN"][str]
	
	return translatedStr or str

end

local function CleanupStrFormat(str)
	
	-- Partial string format
	local formattedStr = string.gsub(str, "$([%w_]*)", function(cleanupType)
		
		local type = SH_ANTICRASH.VARS.CLEANUP.TYPESBYKEY[cleanupType]
		
		if type ~= nil then
			return type.name:lower()
		end
		
		return cleanupType
		
	end)
	
	return formattedStr

end

function SH_ANTICRASH.Format(str)

	local formattedStr = str

	-- Full string format
	if string.StartWith(str,"##") then

		local str = string.sub( str, 3 )
		local strSplitTbl = string.Split(str,' %')
		local translatedStr = SH_ANTICRASH.Translate(strSplitTbl[1])

		-- Keep format parms only
		table.remove(strSplitTbl,1)
		
		-- Replace format parms
		translatedStr = string.format( translatedStr, unpack(strSplitTbl))

		-- Cleanup Format String
		translatedStr = CleanupStrFormat(translatedStr)
		
		formattedStr = translatedStr
		
	end
	
	-- Partial string format
	local formattedStr = string.gsub(formattedStr, "#(%w*)", function(match)
		return SH_ANTICRASH.Translate(match)
	end)
	
	return formattedStr
	
end