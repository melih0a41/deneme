if (easzy.quadcopter.config.language != "es") then return end

easzy.quadcopter.languages = easzy.quadcopter.languages or {}

local languages = easzy.quadcopter.languages

languages.buy = "Comprar"
languages.reset = "Restablecer"
languages.quit = "Salir"
languages.maximum = "Máximo"
languages.remove = "Eliminar"

languages.on = "ENCENDIDO"
languages.off = "APAGADO"
languages.equipments = "EQUIPOS"
languages.colors = "COLORES"
languages.upgrades = "MEJORAS"

languages.pressToRepair = "Presiona E para reparar"
languages.pressToUpgrade = "Presiona E para mejorar"
languages.cameraAngle = "Ángulo de la cámara"

languages.repair = "Reparar"
languages.repairQuadcopter = "Reparar el cuadricóptero"

-- Equipments
languages.c4 = "C4"
languages.camera = "Cámara"
languages.bombHook = "Gancho de bomba"
languages.bomb = "Bomba"
languages.light = "Luz"
languages.speaker = "Altavoz"
languages.battery = "Batería"

languages.c4Description = "Explosivo adjunto al dron."
languages.cameraDescription = "Cámara para control remoto del dron."
languages.bombHookDescription = "Gancho para soltar bombas."
languages.bombDescription = "Bomba para adjuntar al gancho."
languages.lightDescription = "Luz adjunta al dron."
languages.speakerDescription = "Altavoz en el dron."
languages.batteryDescription = "Batería del dron."

languages.c4Information = "Presiona R para detonar"
languages.cameraDJIInformation = "Flechas arriba/abajo para mover la cámara | N para activar la visión nocturna"
languages.cameraFPVInformation = "Flechas arriba/abajo para mover la cámara"
languages.bombInformation = "Presiona R para soltar la bomba"
languages.lightInformation = "Presiona Shift para encender la luz"
languages.speakerInformation = "Presiona E para activar/desactivar el altavoz y mantén la tecla para hablar"

-- Colors
languages.propellers = "Propelas"
languages.motors = "Motores"
languages.frame = "Estructura"

languages.propellersColorDescription = "Cambiar el color de las propelas."
languages.motorsColorDescription = "Cambiar el color de los motores."
languages.frameColorDescription = "Cambiar el color de la estructura."
languages.batteryColorDescription = "Cambiar el color de la batería."

-- Upgrades
languages.speed = "Velocidad"
languages.resistance = "Resistencia"
languages.distance = "Distancia"
languages.battery = "Batería"
languages.untraceable = "Inrastreable"

languages.speedDescription = "Aumentar la velocidad del dron."
languages.resistanceDescription = "Aumentar la resistencia del dron."
languages.distanceDescription = "Aumentar el alcance del dron."
languages.batteryUpgradeDescription = "Aumentar la vida útil de la batería."
languages.untraceableDescription = "Hacer que el dron no sea rastreable por radar."
