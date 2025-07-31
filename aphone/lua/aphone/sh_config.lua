--[[
	Hello there !
	You like the addon ? Mind making a review ? That would be very helpful and it's always nice to see happy people :)
]]--

aphone.GPS = {
	-- Example
	{
		name = "Wood House - Marker",
		vec = Vector(-1531.884644, 2484.743896, 112.031250),
		clr = Color(255, 153, 0),
		icon = "O",
	},

	{
		name = "Wood House - Health",
		vec = Vector(-1531.884644, 2484.743896, 112.031250),
		clr = Color(255, 153, 0),
		icon = "N",
	},

	{
		name = "Wood House - Papers",
		vec = Vector(-1531.884644, 2484.743896, 112.031250),
		clr = Color(255, 153, 0),
		icon = "Q",
		map_restricted = "rp_rockford_v2b",
	},
}

// UNCOMMENT THIS ONLY IF YOUR SERVER CRASH WHEN USING GPS
// aphone.GPSScan = 1000

// Edit there if you want to add painting, However you need to make the player download them yourself
aphone.Painting = {
	[1] = "akulla/aphone/sticker_1.png",
	[2] = "akulla/aphone/sticker_2.png",
	[3] = "akulla/aphone/sticker_3.png",
	[4] = "akulla/aphone/sticker_4.png",
	[5] = "akulla/aphone/sticker_5.png",
	[6] = "akulla/aphone/sticker_6.png",
	[7] = "akulla/aphone/sticker_7.png",
	[8] = "akulla/aphone/sticker_8.png",
	[9] = "akulla/aphone/sticker_9.png",
	[10] = "akulla/aphone/sticker_10.png",
	[11] = "akulla/aphone/sticker_11.png",
	[12] = "akulla/aphone/sticker_12.png",
	[13] = "akulla/aphone/sticker_13.png",
	[14] = "akulla/aphone/sticker_14.png",
	[15] = "akulla/aphone/sticker_15.png",
	[16] = "akulla/aphone/sticker_16.png",
	[17] = "akulla/aphone/sticker_17.png",
	[18] = "akulla/aphone/sticker_18.png",
	[19] = "akulla/aphone/sticker_19.png",
	[20] = "akulla/aphone/sticker_20.png",
	[21] = "akulla/aphone/sticker_21.png",
	[22] = "akulla/aphone/sticker_22.png",
	[23] = "akulla/aphone/sticker_23.png",
	[24] = "akulla/aphone/sticker_24.png",
	[25] = "akulla/aphone/sticker_25.png",
	[26] = "akulla/aphone/sticker_26.png",
	[27] = "akulla/aphone/sticker_27.png",
	[28] = "akulla/aphone/sticker_28.png",
	[29] = "akulla/aphone/sticker_29.png",
	[30] = "akulla/aphone/sticker_30.png",
}

// 8 Numbers/%s please
aphone.Format = "+33 %s%s%s%s%s%s%s%s"

aphone.OthersHearRadio = true
aphone.Language = "english"
aphone.bank_onlytransfer = false
aphone.never_realname = false // Hide RP Name, except in Friends
aphone.disable_showingUnknownPlayers = false
aphone.disable_hitman = false
aphone.disable_smileycamera = false
aphone.agressive_smileys_nodrawDetect = false // Use the hook PrePlayerDraw, can maybe cause issues for addons. Let it to false most of the time

aphone.Links = {
	{
		name = "Shop",
		icon = "akulla/aphone/app_shop.png",
		link = "https://akulla.dev/",
	},
	{
		name = "Discord",
		icon = "akulla/aphone/app_socialserver.png",
		link = "https://akulla.dev/",
	},
}

aphone.SpecialCallsCooldown = 30
aphone.SpecialCalls = {
	{
		name = "Police Call",
		icon = "akulla/aphone/specialcall_police.png",
		teams = {
			[2] = true,
			["Police"] = true,
		},
		desc = "Call police",
	}
}

aphone.Ringtones = {
	{
		name = "Old School",
		url = "https://akulla.dev/aphone/oldschool_ringtone.mp3",
		-- is_local = true, For workshop/fastdl content sounds
	},
}

aphone.DarkWeb = aphone.DarkWeb or {
	config = {
		viewing_jobs = {
			["Citizen"] = true,
		},

		killing_jobs = {
			["Citizen"] = true,
		},

		min = -1, // > 0 to have a min amount
		max = -1 // > 0 to have a max amount
	}
}

aphone.backgrounds_imgur = {
	"3934069807_0",
	"3431138760_0",
	"3208798107_0",
	"3180177695_0",
	"2535473356_0",
	"2398548153_0",
	"2347496489_0",
	"2334774600_0",
	"1970603730_0",
	"1922447093_0",
	"1779062337_0",
	"1630237813_0",
	"1425880340_0",
	"1120643971_0",
	"629892907_0",
	"345797620_0",
	"112759026_0",
	"13029786_0",
	"521609087_0",
	"2847364262_0",
	"2051571912_0",
	"558669269_0",
	"2189059952_0"
}

aphone.RadioList = {
	{
		name = "Rap FR",
		url = "http://urbanhitrapfr.ice.infomaniak.ch/urbanhitrapfr-128.mp3",
		logo = "https://cdn-profiles.tunein.com/s74407/images/logog.png",
		clr = Color(230, 126, 34),
	},
	{
		name = "Rap US",
		url = "https://generationfm-underground.ice.infomaniak.ch/generationfm-underground-high.mp3",
		logo = "https://cdn.onlineradiobox.com/img/l/6/6376.v4.png",
		clr = Color(231, 76, 60),
	},
	{
		name = "NRJ",
		logo = "https://images-eu.ssl-images-amazon.com/images/I/61pw4pjJN9L.png",
		url = "https://scdn.nrjaudio.fm/fr/30001/mp3_128.mp3?cdn_path=adswizz_lbs9",
		clr = Color(255, 100, 100),
	},
	{
		name = "Allzic Chill",
		logo = "https://www.allzicradio.com/media/radios/thumb/195x195_allzic-radio-electro-chillout_1400px.png",
		url = "https://allzic53.ice.infomaniak.ch/allzic53.mp3",
		clr = Color(210, 162, 0),
	},
	{
		name = "Fun Radio",
		logo = "https://images-eu.ssl-images-amazon.com/images/I/61SBhLAGLNL.png",
		url = "http://streamer-01.rtl.fr/fun-1-44-128?listen=webCwsBCggNCQgLDQUGBAcGBg",
		clr = Color(243, 104, 224),
	},
	{
		name = "Mouv'",
		logo = "https://i.imgur.com/lgDfnrA.png",
		url = "http://direct.mouv.fr/live/mouvxtra-midfi.mp3?ID=33c5hej2c2",
		clr = Color(93, 255, 166),
	},
	{
		name = "Skyrock",
		logo = "https://www.radio.net/images/broadcasts/c1/bb/8302/3/c300.png",
		url = "http://icecast.skyrock.net/s/natio_mp3_128k",
		clr = Color(255, 50, 50),
	},
}

aphone.URLUpload = "https://api.akulla.dev/public/uploads/"
aphone.URLupload_picture = "https://api.akulla.dev/upload_picture"
aphone.URLsend_discord = "https://akulla.dev/aphone/send_discord.php"