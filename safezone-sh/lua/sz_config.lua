/**
* General configuration
**/

-- Usergroups allowed to add/modify Safe Zones
SH_SZ.Usergroups = {
	["superadmin"] = true,
	["owner"] = true,
	["founder"] = true,
}

-- If the "Block players from attacking" Safe Zone option is activated,
-- this is the whitelist of SWEPs players are allowed to attack with inside a Safe Zone.
-- Admins are not affected by this option; they can attack with any weapon.
SH_SZ.WeaponWhitelist = {
	["gmod_camera"] = true,
	["weapon_physcannon"] = true,
	["weapon_medkit"] = true,
	["re_hands"] = true,
	["zpf_constructor"] = true,
	["weapon_physgun"] = true,


	
	
}

-- safezone-sh/lua/sz_config.lua dosyasının uygun bir yerine ekleyin

-- Güvenli bölgede araçları silinmeyecek DarkRP mesleklerinin komut adları
SH_SZ.AllowedVehicleJobs = {
    ["zlm_lawnmowerman"] = true,       -- Örnek: "polis" komutuna sahip mesleğin araçları silinmez
    ["doktor"] = true,      -- Örnek: "doktor" komutuna sahip mesleğin araçları silinmez
    ["itfaiyeci"] = true,
    -- Buraya sunucunuzdaki diğer meslek komutlarını ekleyebilirsiniz
    -- Örnek: ["gangster1"] = true,
}

-- Commands to bring up the Safe Zone Editor menu
-- Case/whitespace insensitive, ! commands are automatically replaced by /
SH_SZ.Commands = {
	["/safezones"] = true,
	["/safezone"] = true,
	["/sz"] = true,
}

-- Use Steam Workshop for the content instead of FastDL?
SH_SZ.UseWorkshop = true

-- Controls for the Editor camera.
-- See a full list here: http://wiki.garrysmod.com/page/Enums/KEY
SH_SZ.CameraControls = {
	forward = KEY_W,
	left = KEY_A,
	back = KEY_S,
	right = KEY_D,
}

/**
* HUD configuration
**/

-- Where to display the Safe Zone Indicator on the screen.
-- Possible options: topleft, top, topright, left, center, right, bottomleft, bottom, bottomright
SH_SZ.HUDAlign = "top"

-- Offset of the Indicator relative to its base position.
-- Use this if you want to move the indicator by a few pixels.
SH_SZ.HUDOffset = {
	x = 0,
	y = 0,
	scale = false, -- Set to false/true to enable offset scaling depending on screen resolution.
}

/**
* Advanced configuration
* Edit at your own risk!
**/

SH_SZ.WindowSize = {w = 800, h = 300}

SH_SZ.DefaultOptions = {
	name = "Güvenli Alan",
	namecolor = "52,152,219",
	hud = true,
	noatk = true,
	nonpc = true,
	noprop = true,
	ptime = 5,
	entermsg = "",
	leavemsg = "",
}

SH_SZ.MaximumSize = 1024

SH_SZ.DataDirName = "sh_safezones"

SH_SZ.ZoneHitboxesDeveloper = false

SH_SZ.TeleportIdealDistance = 512

/**
* Theme configuration
**/

-- Font to use for normal text throughout the interface.
SH_SZ.Font = "Circular Std Medium"

-- Font to use for bold text throughout the interface.
SH_SZ.FontBold = "Circular Std Bold"

-- Color sheet. Only modify if you know what you're doing
SH_SZ.Style = {
	header = Color(52, 152, 219, 255),
	bg = Color(52, 73, 94, 255),
	inbg = Color(44, 62, 80, 255),

	close_hover = Color(231, 76, 60, 255),
	hover = Color(255, 255, 255, 10, 255),
	hover2 = Color(255, 255, 255, 5, 255),

	text = Color(255, 255, 255, 255),
	text_down = Color(0, 0, 0),
	textentry = Color(236, 240, 241),
	menu = Color(127, 140, 141),

	success = Color(46, 204, 113),
	failure = Color(231, 76, 60),
}

/**
* Language configuration
**/

-- Various strings used throughout the chatbox. Change them to your language here.
-- %s and %d are special strings replaced with relevant info, keep them in the string!

SH_SZ.Language = {
    safezone = "Güvenli Bölge",
    safezone_type = "Güvenli Bölge Türü",
    cube = "Küp",
    sphere = "Küre",

    select_a_safezone = "Bir güvenli bölge seçin",

    options = "Seçenek",
    name = "İsim",
    name_color = "İsim Rengi",
    enable_hud_indicator = "HUD göstergesini etkinleştir",
    delete_non_admin_props = "Admin olmayan eşyaları sil",
    prevent_attacking_with_weapons = "Silahlarla saldırmayı engelle",
    automatically_remove_npcs = "NPC'leri otomatik kaldır",
    time_until_protection_enables = "Korumanın etkinleşmesine kalan süre",
    enter_message = "Giriş mesajı",
    leave_message = "Çıkış mesajı",

    will_be_protected_in_x = "Güvenli bölgeye girmek üzeresin, %s saniye",
    safe_from_damage = "Hasar almazsınız.",

    place_point_x = "Yer noktasının numarası: fareyle %d",
    size = "Boyut",
    finalize_placement = "Yerleştirmeyi tamamlayın ve \"Onayla\"ya tıklayın",

    add = "Ekle",
    edit = "Düzenle",
    fill_vertically = "Dikey doldur",
    reset = "Sıfırla",
    confirm = "Onayla",
    teleport_there = "Oraya ışınlan",
    save = "Kaydet",
    delete = "Sil",
    cancel = "İptal",
    move_camera = "Kamerayı taşı",
    rotate_camera = "SAĞ TIK: kamera döndür",

    an_error_has_occured = "Bir hata oluştu. Sunucuyu yeniden başlatıp tekrar deneyin.",
    not_allowed = "Bu işlemi yapmaya yetkiniz yok.",
    safe_zone_created = "Güvenli bölge başarıyla oluşturuldu!",
    safe_zone_edited = "Güvenli bölge başarıyla düzenlendi!",
    safe_zone_deleted = "Güvenli bölge başarıyla silindi!",
}
