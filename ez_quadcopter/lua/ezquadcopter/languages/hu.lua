if (easzy.quadcopter.config.language != "hu") then return end

easzy.quadcopter.languages = easzy.quadcopter.languages or {}

local languages = easzy.quadcopter.languages

languages.buy = "Vásárlás"
languages.reset = "Visszaállítás"
languages.quit = "Kilépés"
languages.maximum = "Maximális"
languages.remove = "Eltávolítás"

languages.on = "ON"
languages.off = "OFF"
languages.equipments = "FELSZERELÉSEK"
languages.colors = "SZÍNEK"
languages.upgrades = "FEJLESZTÉSEK"

languages.pressToRepair = "Nyomja meg az E-t a javításhoz"
languages.pressToUpgrade = "Nyomja meg az E-t a fejlesztéshez"
languages.cameraAngle = "Kamera szöge"

languages.repair = "Javítás"
languages.repairQuadcopter = "Quadcopter javítása"

-- Equipments
languages.c4 = "C4"
languages.camera = "Kamera"
languages.bombHook = "Bomba kampó"
languages.bomb = "Bomba"
languages.light = "Fény"
languages.speaker = "Hangszóró"
languages.battery = "Akkumulátor"

languages.c4Description = "A drónhoz rögzített robbanószer."
languages.cameraDescription = "Kamera a drón távvezérléséhez."
languages.bombHookDescription = "Kampó bombák ledobásához."
languages.bombDescription = "A kampóra rögzíthető bomba."
languages.lightDescription = "A drónhoz rögzített fény."
languages.speakerDescription = "Hangszóró a drónon."
languages.batteryDescription = "Drón akkumulátor."

languages.c4Information = "Robbantáshoz nyomja meg az R gombot"
languages.cameraDJIInformation = "Kameramozgatáshoz nyomja meg a fel/le nyilat | N éjjellátás aktiválásához"
languages.cameraFPVInformation = "Kameramozgatáshoz nyomja meg a fel/le nyilat"
languages.bombInformation = "Bombaleejtéshez nyomja meg az R gombot"
languages.lightInformation = "Fény bekapcsolásához nyomja meg a Shift gombot"
languages.speakerInformation = "Hangszóró be/ki kapcsoláshoz nyomja meg az E gombot, és tartsa lenyomva a beszédhez"

-- Colors
languages.propellers = "Propellerek"
languages.motors = "Motorok"
languages.frame = "Váz"

languages.propellersColorDescription = "A propellerek színének megváltoztatása."
languages.motorsColorDescription = "A motorok színének megváltoztatása."
languages.frameColorDescription = "A váz színének megváltoztatása."
languages.batteryColorDescription = "Az akkumulátor színének megváltoztatása."

-- Upgrades
languages.speed = "Sebesség"
languages.resistance = "Ellenállás"
languages.distance = "Hatótávolság"
languages.battery = "Akkumulátor"
languages.untraceable = "Nyomon követhetetlen"

languages.speedDescription = "A drón sebességének növelése."
languages.resistanceDescription = "A drón ellenállásának növelése."
languages.distanceDescription = "A drón hatótávolságának növelése."
languages.batteryUpgradeDescription = "Az akkumulátor élettartamának növelése."
languages.untraceableDescription = "A drónt radar által nyomon követhetetlenné teszi."
