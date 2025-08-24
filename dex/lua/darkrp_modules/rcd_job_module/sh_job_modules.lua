DarkRP.createCategory{
    name = "Criminals",
    categorises = "jobs",
    startExpanded = true,
    color = Color(255, 0, 0, 255),
    sortOrder = 100,
}

TEAM_SERIALKILLER = DarkRP.createJob("Serial Killer", {
    color = Color(139, 0, 0, 255),
    model = {"models/player/phoenix.mdl"},
    description = [[You are a serial killer. Your goal is to eliminate players without getting caught.
    Kill silently and escape without leaving a trace. Do not kill in public or you will be wanted.]],
    weapons = {"weapon_knife", "lockpick"},
    command = "serialkiller",
    max = 1,
    salary = 25,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Criminals",
})