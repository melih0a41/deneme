if (easzy.quadcopter.config.language != "uk") then return end

easzy.quadcopter.languages = easzy.quadcopter.languages or {}

local languages = easzy.quadcopter.languages

languages.buy = "Купити"
languages.reset = "Скинути"
languages.quit = "Вийти"
languages.maximum = "Максимум"
languages.remove = "Видалити"

languages.on = "УВІМКНЕНО"
languages.off = "ВИМКНЕНО"
languages.equipments = "ОБЛАДНАННЯ"
languages.colors = "КОЛЬОРИ"
languages.upgrades = "ОНОВЛЕННЯ"

languages.pressToRepair = "Натисніть E для ремонту"
languages.pressToUpgrade = "Натисніть E для оновлення"
languages.cameraAngle = "Кут камери"

languages.repair = "Ремонт"
languages.repairQuadcopter = "Ремонт квадрокоптера"

-- Equipments
languages.c4 = "С4"
languages.camera = "Камера"
languages.bombHook = "Гачок для бомби"
languages.bomb = "Бомба"
languages.light = "Світло"
languages.speaker = "Динамік"
languages.battery = "Батарея"

languages.c4Description = "Вибухівка, прикріплена до дрона."
languages.cameraDescription = "Камера для дистанційного керування дроном."
languages.bombHookDescription = "Гачок для скидання бомб."
languages.bombDescription = "Бомба для кріплення до гачка."
languages.lightDescription = "Світло, прикріплене до дрона."
languages.speakerDescription = "Динамік на дроні."
languages.batteryDescription = "Батарея дрона."

languages.c4Information = "Натисніть R, щоб підірвати"
languages.cameraDJIInformation = "Стрілки вгору/вниз для переміщення камери | N для активації нічного бачення"
languages.cameraFPVInformation = "Стрілки вгору/вниз для переміщення камери"
languages.bombInformation = "Натисніть R, щоб скинути бомбу"
languages.lightInformation = "Натисніть Shift, щоб увімкнути світло"
languages.speakerInformation = "Натисніть E, щоб увімкнути/вимкнути динамік і утримуйте клавішу для розмови"

-- Colors
languages.propellers = "Пропелери"
languages.motors = "Мотори"
languages.frame = "Рама"

languages.propellersColorDescription = "Змінити колір пропелерів."
languages.motorsColorDescription = "Змінити колір моторів."
languages.frameColorDescription = "Змінити колір рами."
languages.batteryColorDescription = "Змінити колір батареї."

-- Upgrades
languages.speed = "Швидкість"
languages.resistance = "Стійкість"
languages.distance = "Дальність"
languages.battery = "Батарея"
languages.untraceable = "Невідстежуваний"

languages.speedDescription = "Збільшення швидкості дрона."
languages.resistanceDescription = "Збільшення стійкості дрона."
languages.distanceDescription = "Збільшення дальності дрона."
languages.batteryUpgradeDescription = "Збільшення тривалості роботи батареї."
languages.untraceableDescription = "Робить дрон невідстежуваним радаром."
