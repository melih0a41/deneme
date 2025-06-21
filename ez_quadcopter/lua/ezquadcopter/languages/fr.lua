if (easzy.quadcopter.config.language != "fr") then return end

easzy.quadcopter.languages = easzy.quadcopter.languages or {}

local languages = easzy.quadcopter.languages

languages.buy = "Acheter"
languages.reset = "Réinitialiser"
languages.quit = "Quitter"
languages.maximum = "Maximum"
languages.remove = "Retirer"

languages.on = "ON"
languages.off = "OFF"
languages.equipments = "EQUIPEMENTS"
languages.colors = "COLORS"
languages.upgrades = "UPGRADES"

languages.pressToRepair = "Appuyer sur E pour réparer"
languages.pressToUpgrade = "Appuyer sur E pour améliorer"
languages.cameraAngle = "Angle de la caméra"

languages.repair = "Réparer"
languages.repairQuadcopter = "Réparer le drone"

-- Equipements
languages.c4 = "C4"
languages.camera = "Caméra"
languages.bombHook = "Crochet à bombe"
languages.bomb = "Bombe"
languages.light = "Lampe"
languages.speaker = "Haut-parleur"
languages.battery = "Batterie"

languages.c4Description = "Explosif attaché au drone."
languages.cameraDescription = "Caméra pour voir ou est le drone."
languages.bombHookDescription = "Crochet pour larguer des bombes."
languages.bombDescription = "Bombe à attacher au crochet."
languages.lightDescription = "Lampe attachée au drone."
languages.speakerDescription = "Haut-parleur sur le drone."
languages.batteryDescription = "Batterie du drone."

languages.c4Information = "R pour exploser"
languages.cameraDJIInformation = "Flèches haut/bas pour déplacer la caméra | N pour activer la vision nocture"
languages.cameraFPVInformation = "Flèches haut/bas pour déplacer la caméra"
languages.bombInformation = "R pour larguer la bombe"
languages.lightInformation = "Shift pour allumer la lampe"
languages.speakerInformation = "E pour activer/désactiver le haut-parleur et maintenir votre touche pour parler"

-- Colors
languages.propellers = "Hélices"
languages.motors = "Moteurs"
languages.frame = "Chassis"

languages.propellersColorDescription = "Changer la couleur des hélices."
languages.motorsColorDescription = "Changer la couleur des moteurs."
languages.frameColorDescription = "Changer la couleur du chassis."
languages.batteryColorDescription = "Changer la couleur de la batterie."

-- Upgrades
languages.speed = "Vitesse"
languages.resistance = "Résistance"
languages.distance = "Distance"
languages.battery = "Batterie"
languages.untraceable = "Intracable"

languages.speedDescription = "Augmenter la vitesse du drone."
languages.resistanceDescription = "Augmenter la résistance du drone."
languages.distanceDescription = "Augmenter la portée du drone."
languages.batteryUpgradeDescription = "Augmenter l'autonomie de la batterie."
languages.untraceableDescription = "Rend le drone intracable par les radars."
