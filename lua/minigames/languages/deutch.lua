--[[--------------------------------------------
                Deutch Translation
--------------------------------------------]]--

-- Übersetzung von Gamer688
-- https://www.gmodstore.com/users/gamer688
Minigames.Language["deutsch"] = {

    ["tool.desc"] = "Verwende dieses Werkzeug, um Minispiele automatisch zu erstellen",
    ["tool.left"] = "Minispiele erstellen - Spieler zum Minispiel hinzufügen/entfernen",
    ["tool.right"] = "Minispiele einrichten",
    ["tool.reload"] = "Spezielle Option, z. B. das Minispiel pausieren",

    ["setupmenu.title"] = "Minispiel-Werkzeugassistent - Einrichtungsmenü",
    ["setupmenu.togglegame"] = "Aktuelles Minispiel starten / stoppen",
    ["setupmenu.players"] = "Aktuelle Spieler",

    ["configmenu.title"] = "Minispiel-Tool-Assistent - Konfiguration",
    ["configmenu.shortcuts"] = "Konfigurationsverknüpfungen",
    ["configmenu.yes"] = "Ja",
    ["configmenu.no"] = "Nein",
    ["configmenu.true"] = "Wahr",
    ["configmenu.false"] = "Falsch",
    ["configmenu.table.addrow"] = "Zeile hinzufügen",
    ["configmenu.table.addrow.desc"] = "Fügen Sie der Zeile einen neuen Wert hinzu",
    ["configmenu.table.edit"] = "Bearbeiten",
    ["configmenu.table.edit.desc"] = "Wert bearbeiten",
    ["configmenu.table.delete"] = "Löschen",
    ["configmenu.table.copy"] = "Kopieren",

    ["configmenu.botscantalk"] = "Bots können sprechen",
    ["configmenu.botscantalk.desc"] = [[Bots in Minispielen können Kommentare wie "Das ist in Ordnung" oder "Ich glaube nicht" abgeben]],
    ["configmenu.bottalkvolume"] = "Bot-Lautstärke",
    ["configmenu.bottalkvolume.desc"] = "Lautstärke der Bots beim Sprechen (Standardmäßig: 75)",
    ["configmenu.botcomment"] = "Bot-Kommentar",
    ["configmenu.botcomment.desc"] = [[Bots können die folgenden Audios verwenden, um Kommentare "Positiv", "Negativ" oder "Neutral" abzugeben]],
    ["configmenu.botcomment.comments"] = "Liste der neutralen Kommentare",
    ["configmenu.botcomment.comments.subtitle"] = "Neutrale Kommentare",
    ["configmenu.botcomment.positive"] = "Liste der positiven Kommentare",
    ["configmenu.botcomment.positive.subtitle"] = "Positive Kommentare",
    ["configmenu.botcomment.negative"] = "Liste der negativen Kommentare",
    ["configmenu.botcomment.negative.subtitle"] = "Negative Kommentare",
    ["configmenu.togglegameshortcut"] = "Tastenkombination",
    ["configmenu.togglegameshortcut.desc"] = [[Das Festlegen dieser Funktioniert als Verknüpfung, diese Verknüpfung hat die gleiche Funktion wie die Schaltfläche zum Starten / Stoppen des Minispiels]],
    ["configmenu.blurvgui"] = "Menü mit Unschärfe",
    ["configmenu.blurvgui.desc"] = "Durch Festlegen wird das Menü einen Unschärfeeffekt haben",
    ["configmenu.playsounds"] = "Aktiviere Sounds",
    ["configmenu.playsounds.desc"] = "Aktiviert die Sounds oder alles, was ein Addon emittiert",
    ["configmenu.onbegingamesound"] = "Musik beim Start des Spiels",
    ["configmenu.onbegingamesound.desc"] = "Die Musik, die beim Start eines beliebigen Minispiels zu hören ist, ist dieser Pfad relativ zu 'sound/...'",
    ["configmenu.onwingamesound"] = "Musik beim Gewinnen",
    ["configmenu.onwingamesound.desc"] = "Die Musik, die der Gewinner hören wird",
    ["configmenu.allowusergroup"] = "Erlaubte Benutzergruppen",
    ["configmenu.allowusergroup.desc"] = "Die Benutzergruppen oder Benutzergruppen, die Zugriff auf das Erstellen von Minispielen haben. Der Superadmin hat immer Zugriff.",
    ["configmenu.allowusergroup.key"] = "Gruppe / Benutzergruppe",
    ["configmenu.allowusergroup.value"] = "Hat Berechtigungen",
    ["configmenu.stripweaponsongame"] = "Waffen entfernen",
    ["configmenu.stripweaponsongame.desc"] = "Wenn Spieler ein Minispiel betreten, werden ihnen während des Spiels alle Waffen entzogen. Nachdem sie verloren oder gestorben sind, erhalten sie alle Waffen zurück",
    ["configmenu.greenlight"] = "Grünes Licht Sound",
    ["configmenu.greenlight.desc"] = "(Nur in Red Light Green Light verfügbar) Der Sound, der abgespielt wird, wenn Sie Green Light sagen",
    ["configmenu.redlight"] = "Rotes Licht Sound",
    ["configmenu.redlight.desc"] = "(Nur in Red Light Green Light verfügbar) Der Sound, der abgespielt wird, wenn Sie Red Light sagen",
    ["configmenu.preventdamage"] = "Verhindern Sie Schäden",
    ["configmenu.preventdamage.desc"] = "Spieler erhalten keinen externen Schaden von Minispielen, nützlich, um zu verhindern, dass sie sich gegenseitig töten",
    ["configmenu.preventnoclip"] = "Verhindern Sie das Noclip",
    ["configmenu.preventnoclip.desc"] = "(Sandbox) Verhindert, dass Spieler während des Minispiels noclip verwenden, dies gilt auch für das Personal",
    ["configmenu.language"] = "Hauptsprache",
    ["configmenu.language.desc"] = "Die Hauptsprache, die das Addon haben wird (kann in Echtzeit geändert werden)",

    ["reward.title"] = "Belohnungen",
    ["reward.desc"] = [[Belohnungen werden am Ende des Minispiels vergeben.
Der gewinnende Spieler wird die Belohnung entsprechend dem ausgewählten Betrag erhalten.]],
    ["reward.onlyone"] = "Die belohnung ist das %str selbst.",

    ["minigames.title"] = "Minispiele",
    ["minigames.onjoin"] = "%ply ist dem Spiel beigetreten",
    ["minigames.onleft"] = "%ply hat das Spiel verlassen",
    ["minigames.onwin"] = "%ply hat das Spiel gewonnen und %str erhalten!",
    ["minigames.onlose"] = "%ply hat das Spiel verloren!",

    ["minigames.player.cantjoin"] = "%ply kann dem Spiel nicht beitreten, möglicherweise ist er bereits in einem Spiel oder einem anderen Minispiel!",
    ["minigames.player.cantjoin.dead"] = "Der Spieler %ply ist tot!",
    ["minigames.player.cantjoin.you"] = "Sie können diesem Spiel nicht beitreten!",
    ["minigames.player.cantjoin.owner"] = "Dieser Spieler kann Ihrem Spiel nicht beitreten!",

    ["minigames.error.gameisactive"] = "Du musst das Spiel beenden, bevor du es entfernen kannst!",
    ["minigames.error.gamedontexists"] = "Dieses Minispiel existiert nicht!",
    ["minigames.error.gameneed"] = "Sie haben noch kein Spiel erstellt!",

    -- Das Spiel der fallenden Plattformen, ähnlich wie Fall Guys
    ["plataforms.name"] = "Plattformen",
    ["plataforms.desc"] = "Ein Plattformspiel, bei dem das Ziel darin besteht, nicht herunterzufallen, während pro Runde immer mehr Quadrate verschwinden.",
    ["plataforms.sizex"] = "Breite",
    ["plataforms.sizex.desc"] = "Wie viele Quadrate sollen in der X-Achse des Spiels generiert werden",
    ["plataforms.sizey"] = "Länge",
    ["plataforms.sizey.desc"] = "Wie viele Quadrate sollen in der Y-Achse des Spiels generiert werden",
    ["plataforms.increment"] = "Inkrement",
    ["plataforms.increment.desc"] = "Erhöhung der Plattformen, die pro Runde verschwinden müssen",
    ["plataforms.min"] = "Start (Minimum)",
    ["plataforms.min.desc"] = "Mit wie vielen Plattformen soll das Spiel beginnen?",
    ["plataforms.max"] = "Ende (Maximum)",
    ["plataforms.max.desc"] = "Wie viele Plattformen sollen höchstens verschwinden",
    ["plataforms.timereaction"] = "Reaktionszeit",
    ["plataforms.timereaction.desc"] = "Zeit, die die Spieler haben, um zu reagieren, bevor die Plattform verschwindet",
    ["plataforms.offset"] = "Abstand",
    ["plataforms.offset.desc"] = "Bereich des Abstands zwischen jeder Plattform.",
    ["plataforms.height"] = "Höhe",
    ["plataforms.height.desc"] = "Die Höhe, in der das Spiel erstellt wird",


    -- Drop Out
    -- Dieser Name ist im Spanischen nicht übersetzbar
    -- Aber hey, klingt cool auf Englisch
    ["dropout.name"] = "Drop Out",
    ["dropout.desc"] = "Ein Plattformspiel, bei dem das Ziel darin besteht, nicht herunterzufallen, während die Plattformen vollständig verschwinden.",
    ["dropout.sizex"] = "Breite",
    ["dropout.sizex.desc"] = "Wie viele Quadrate sollen in der X-Achse des Spiels generiert werden",
    ["dropout.sizey"] = "Länge",
    ["dropout.sizey.desc"] = "Wie viele Quadrate sollen in der Y-Achse des Spiels generiert werden",
    ["dropout.increment"] = "Inkrement",
    ["dropout.increment.desc"] = "Erhöhung der Plattformen, die pro Runde verschwinden müssen",
    ["dropout.delay"] = "Verzögerung",
    ["dropout.delay.desc"] = "Zeit, bis die Plattform vollständig verschwindet",
    ["dropout.timereaction"] = "Reaktionszeit",
    ["dropout.timereaction.desc"] = "Zeit, die die Spieler haben, um zu reagieren, bevor die Plattform verschwindet",
    ["dropout.offset"] = "Abstand",
    ["dropout.offset.desc"] = "Bereich des Abstands zwischen jeder Plattform.",
    ["dropout.height"] = "Höhe",
    ["dropout.height.desc"] = "Die Höhe, in der das Spiel erstellt wird",


    -- Rot-Licht-Grün-Licht
    ["cigarrillo43.name"] = "Rot-Licht-Grün-Licht",
    ["cigarrillo43.desc"] = "Die Spieler müssen den Weg bis zum Ende durchlaufen, der erste Spieler, der das Ende erreicht, ist der Gewinner",
    ["cigarrillo43.sizex"] = "Breite",
    ["cigarrillo43.sizex.desc"] = "Wie viele Quadrate sollen in der X-Achse des Spiels generiert werden",
    ["cigarrillo43.sizey"] = "Länge",
    ["cigarrillo43.sizey.desc"] = "Wie viele Quadrate sollen in der Y-Achse des Spiels generiert werden",
    ["cigarrillo43.safetime"] = "Reaktionszeit",
    ["cigarrillo43.safetime.desc"] = "Wie viel Zeit (in Sekunden) haben die Spieler, um zu reagieren und sich zu bewegen, wenn es Rotlicht ist",
    ["cigarrillo43.height"] = "Höhe",
    ["cigarrillo43.height.desc"] = "Die Höhe, in der das Spiel erstellt wird",


    -- Simon Says
    --["simonsays.name"] = "",
    --["simonsays.desc"] = "",
    ["simonsays.sizex"] = "Breite",
    ["simonsays.sizex.desc"] = "Wie viele Quadrate sollen in der X-Achse des Spiels generiert werden",
    ["simonsays.sizey"] = "Länge",
    ["simonsays.sizey.desc"] = "Wie viele Quadrate sollen in der Y-Achse des Spiels generiert werden",
    ["simonsays.offset"] = "Abstand",
    ["simonsays.offset.desc"] = "Bereich des Abstands zwischen jeder Plattform.",
    ["simonsays.safetime"] = "Reaktionszeit",
    ["simonsays.safetime.desc"] = "Wie viel Zeit (in Sekunden) haben die Spieler, um zu reagieren und sich zu bewegen, wenn es Rotlicht ist",
    ["simonsays.height"] = "Höhe",
    ["simonsays.height.desc"] = "Die Höhe, in der das Spiel erstellt wird",

}