gProtect = gProtect or {}
gProtect.config = gProtect.config or {}

gProtect.config.Prefix = "[gProtect] "

gProtect.config.FrameSize = {x = 720, y = 530}

gProtect.config.SelectedLanguage = "en"

gProtect.config.StorageType = "sql_local" -- (sql_local, mysql)

gProtect.config.EnableOwnershipHUD = true

gProtect.config.IgnoreEntitiesHUD = { -- Entities in this list will be ignored by the ray used for the ownership HUD.
	["mg_viewmodel"] = true,
}

gProtect.config.DisableOwnershipRayDetection = false -- Enable this if you dont have fading doors and such to slightly improve performance.

gProtect.config.DisableBuddySystem = false

gProtect.config.HideToolsInSpawnMenu = true -- Enable this to hide tools and categories if you dont have permission to use them

gProtect.config.Permissions = {
	["gProtect_Settings"] = { -- This is for modifying the values in gProtect
		["owner"] = true,
		["superadmin"] = true
	},
	["gProtect_StaffNotifications"] = { -- These groups will receive notifications from detections
		["owner"] = true,
		["superadmin"] = true
	},
	["gProtect_DashboardAccess"] = { -- These groups will be able to open the gProtect menu
		["owner"] = true,
		["superadmin"] = true
	}
}