if (easzy.quadcopter.config.language != "ru") then return end

easzy.quadcopter.languages = easzy.quadcopter.languages or {}

local languages = easzy.quadcopter.languages

languages.buy = "Купить"
languages.reset = "Сброс"
languages.quit = "Выход"
languages.maximum = "Максимум"
languages.remove = "Удалить"

languages.on = "ВКЛ"
languages.off = "ВЫКЛ"
languages.equipments = "ОБОРУДОВАНИЕ"
languages.colors = "ЦВЕТА"
languages.upgrades = "УЛУЧШЕНИЯ"

languages.pressToRepair = "Нажмите E для ремонта"
languages.pressToUpgrade = "Нажмите E для улучшения"
languages.cameraAngle = "Угол камеры"

languages.repair = "Ремонт"
languages.repairQuadcopter = "Ремонт квадрокоптера"

-- Equipments
languages.c4 = "С4"
languages.camera = "Камера"
languages.bombHook = "Крючок для бомбы"
languages.bomb = "Бомба"
languages.light = "Свет"
languages.speaker = "Динамик"
languages.battery = "Батарея"

languages.c4Description = "Взрывчатка, прикрепленная к дрону."
languages.cameraDescription = "Камера для дистанционного управления дроном."
languages.bombHookDescription = "Крючок для сброса бомб."
languages.bombDescription = "Бомба для крепления к крючку."
languages.lightDescription = "Свет, прикрепленный к дрону."
languages.speakerDescription = "Динамик на дроне."
languages.batteryDescription = "Батарея дрона."

languages.c4Information = "Нажмите R, чтобы взорвать"
languages.cameraDJIInformation = "Стрелки вверх/вниз для перемещения камеры | N для активации ночного видения"
languages.cameraFPVInformation = "Стрелки вверх/вниз для перемещения камеры"
languages.bombInformation = "Нажмите R, чтобы сбросить бомбу"
languages.lightInformation = "Нажмите Shift, чтобы включить свет"
languages.speakerInformation = "Нажмите E, чтобы включить/выключить динамик и удерживайте клавишу, чтобы говорить"

-- Colors
languages.propellers = "Пропеллеры"
languages.motors = "Моторы"
languages.frame = "Рама"

languages.propellersColorDescription = "Изменить цвет пропеллеров."
languages.motorsColorDescription = "Изменить цвет моторов."
languages.frameColorDescription = "Изменить цвет рамы."
languages.batteryColorDescription = "Изменить цвет батареи."

-- Upgrades
languages.speed = "Скорость"
languages.resistance = "Прочность"
languages.distance = "Расстояние"
languages.battery = "Батарея"
languages.untraceable = "Неотслеживаемый"

languages.speedDescription = "Увеличить скорость дрона."
languages.resistanceDescription = "Увеличить прочность дрона."
languages.distanceDescription = "Увеличить дальность полета дрона."
languages.batteryUpgradeDescription = "Увеличить срок службы батареи."
languages.untraceableDescription = "Сделать дрон неотслеживаемым радаром."
