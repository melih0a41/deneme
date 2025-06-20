--[[--------------------------------------------
                Перевод на русский
--------------------------------------------]]--

-- Могут быть ошибки, но Калумб не виноват в них, | VinSKy | Apach
-- Я изо всех сил старался перевести это, даже если не знаю русского. vicentefelipechile
Minigames.Language["russian"] = {
    -- General
    ["tool.desc"] = "Используйте этот инструмент для автоматического создания мини-игр",
    ["tool.left"] = "Создать мини-игры - Добавить/Удалить игроков из вашей мини-игры",
    ["tool.right"] = "Настройка мини-игр",
    ["tool.reload"] = "Специальная опция, например: Приостановить мини-игру",
    ["tool.singleplayer"] = "Предупреждение: Вы играете в одиночном режиме, кнопка перезагрузки не будет работать правильно",

    ["setupmenu.title"] = "Помощник по настройке инструмента мини-игр - Настройка",
    ["setupmenu.togglegame"] = "Запустить / Остановить текущую мини-игру",
    ["setupmenu.players"] = "Текущие игроки",

    ["reward.title"] = "Награды",
    ["reward.select"] = "Выберите награду",
    ["reward.desc"] = "Награды выдаются в конце мини-игры. \nПобедивший игрок получит награду в соответствии с выбранным и количеством.",
    ["reward.onlyone"] = "Приз одинаковый %str",
    ["reward.nothing"] = "Награда не выбрана",
    ["reward.disabled"] = "У вас должна быть готова игра, чтобы добавить награды",
    ["reward.add"] = "Добавить награду",
    ["reward.none"] = "%ply выиграла мини-игру!",
    ["reward.given"] = "%ply выиграл %str!",

    ["playerlist.add"] = "Добавить игрока",
    ["playerlist.remove"] = "Удалить игрока",
    ["playerlist.toggle"] = "Переключить игрока",
    ["playerlist.sendtogame"] = "Отправить игрока в мини-игру",
    ["playerlist.sendtooldpos"] = "Отправить игрока на его предыдущую позицию",
    ["playerlist.sendtospawn"] = "Отправить игрока на его спавн",
    ["playerlist.mute"] = "Заглушить игрока",
    ["playerlist.unmute"] = "Отменить заглушку игрока",
    ["playerlist.hearowner"] = "Игроки могут слышать владельца",
    ["playerlist.muteall"] = "Заглушить всех игроков",
    ["playerlist.hearself"] = "Использовать голос без проксимити",

    ["playerlist.broadcast"] = "Создать объявление для присоединения к мини-игре",
    ["playerlist.broadcast.alreadywaiting"] = "В настоящее время другой владелец мини-игры ищет игроков, дождитесь его завершения, прежде чем использовать это",
    ["playerlist.broadcast.join"] = "%ply организует мини-игру, присоединяйтесь, набрав в чате: %str",
    ["playerlist.broadcast.gameremoved"] = "Мини-игра %ply была отменена",
    ["playerlist.broadcast.gamestarted"] = "Мини-игра %ply уже началась, больше записей не принимается",

    ["minigames.title"] = "Мини-игры",
    ["minigames.desc"] = "Описание:",
    ["minigames.gameconfig"] = "Конфигурация игры",
    ["minigames.playzoneconfig"] = "Игровая зона",
    ["minigames.onjoin"] = "Игрок %ply присоединился к игре",
    ["minigames.onleft"] = "Игрок %ply покинул игру",
    ["minigames.onlose"] = "%ply проиграл игру!",
    ["minigames.gamestopped"] = "Мини-игра отменена, никто не победил!",
    ["minigames.removeyourgame"] = "Удалите свою текущую игру, прежде чем перейти к другой",

    ["minigames.player.notingame"] = "Игрок %ply не участвует в игре!",
    ["minigames.player.alreadyingame"] = "Игрок %ply уже участвует в игре!",
    ["minigames.player.cantjoin"] = "Игрок %ply не может присоединиться к вашей игре, он уже участвует в другой или принадлежит другой!",
    ["minigames.player.cantjoin.dead"] = "Игрок %ply мертв!",
    ["minigames.player.cantjoin.you"] = "Вы не можете присоединиться к этой игре!",
    ["minigames.player.cantjoin.owner"] = "Этот игрок не может присоединиться к вашей игре!",

    ["minigames.error.gameisactive"] = "Вы должны остановить свою игру перед удалением!",
    ["minigames.error.gamedontexists"] = "Такой мини-игры не существует!",
    ["minigames.error.gameneed"] = "Вы еще не создали игру!",

    ["minigame_ammo"] = "Боеприпасы",
    ["minigame_health"] = "Здоровье",
    ["minigame_spawnpoint"] = "Точка возрождения",
    ["minigame_weapon"] = "Оружие",
    ["minigame_armor"] = "Броня",

    -- Платформы
    ["plataforms.name"] = "Платформы",
    ["plataforms.desc"] = "Игра на платформе, цель - избежать падения, пока постепенно исчезают все больше платформ за раунд.",
    ["plataforms.tip"] = "Чтобы приостановить игру, используйте клавишу перезагрузки (R)",
    ["plataforms.sizex"] = "Ширина",
    ["plataforms.sizex.desc"] = "Количество платформ, которые будут созданы в ширину в игре",
    ["plataforms.sizey"] = "Длина",
    ["plataforms.sizey.desc"] = "Количество платформ, которые будут созданы в длину в игре",
    ["plataforms.increment"] = "Прирост за раунд",
    ["plataforms.increment.desc"] = "Количество платформ, которые должны исчезнуть за раунд",
    ["plataforms.delay"] = "Задержка",
    ["plataforms.delay.desc"] = "Время до полного исчезновения платформы",
    ["plataforms.min"] = "Начало (Минимум)",
    ["plataforms.min.desc"] = "Минимальный процент платформ, с которым начнется игра",
    ["plataforms.max"] = "Конец (Максимум)",
    ["plataforms.max.desc"] = "Максимальный процент платформ, которые должны исчезнуть",
    ["plataforms.timereaction"] = "Время реакции",
    ["plataforms.timereaction.desc"] = "Время, которое игроки имеют для реакции, прежде чем платформа исчезнет",
    ["plataforms.offset"] = "Расстояние",
    ["plataforms.offset.desc"] = "Расстояние разделения, которое будет между каждой платформой",
    ["plataforms.height"] = "Высота",
    ["plataforms.height.desc"] = "Высота, на которой будет создана игра",

    -- Drop Out
    ["dropout.name"] = "Постоянный Выпадение",
    ["dropout.desc"] = "Игра на платформе, цель - избежать падения, пока платформы исчезают навсегда.",
    ["dropout.tip"] = "Чтобы приостановить игру, используйте клавишу перезагрузки (R)",
    ["dropout.sizex"] = "Ширина",
    ["dropout.sizex.desc"] = "Ширина игры в платформах",
    ["dropout.sizey"] = "Длина",
    ["dropout.sizey.desc"] = "Длина игры в платформах",
    ["dropout.increment"] = "Прирост за раунд",
    ["dropout.increment.desc"] = "Платформы, которые исчезнут за раунд",
    ["dropout.delay"] = "Время за раунд",
    ["dropout.delay.desc"] = "Сколько времени пройдет с момента исчезновения платформы до следующего исчезновения",
    ["dropout.timereaction"] = "Время реакции",
    ["dropout.timereaction.desc"] = "Время, которое игроки имеют для реакции, прежде чем платформа исчезнет",
    ["dropout.offset"] = "Расстояние",
    ["dropout.offset.desc"] = "Расстояние разделения, которое будет между каждой платформой",
    ["dropout.height"] = "Высота",
    ["dropout.height.desc"] = "Высота, на которой будет создана игра",

    -- Luz Roja Luz Verde
    ["cigarrillo43.name"] = "Красный Свет Зеленый Свет",
    ["cigarrillo43.desc"] = "Игроки должны пройти по пути, чтобы дойти до конца, первый игрок, который дойдет, победитель.",
    ["cigarrillo43.tip"] = "Чтобы чередовать красный и зеленый свет, используйте клавишу перезагрузки (R)",
    ["cigarrillo43.sizex"] = "Ширина",
    ["cigarrillo43.sizex.desc"] = "Количество платформ, которые будут созданы в ширину в игре",
    ["cigarrillo43.sizey"] = "Длина",
    ["cigarrillo43.sizey.desc"] = "Количество платформ, которые будут созданы в длину в игре",
    ["cigarrillo43.safetime"] = "Время реакции",
    ["cigarrillo43.safetime.desc"] = "Сколько времени (в секундах) игроки имеют для реакции и остановки, когда они говорят Красный Свет",
    ["cigarrillo43.height"] = "Высота",
    ["cigarrillo43.height.desc"] = "Высота, на которой будет создана игра",
    ["cigarrillo43.onespawn"] = "Один спавн",
    ["cigarrillo43.onespawn.desc"] = "Активируя это, игроки появятся в одном спавне",

    -- Simon dice
    ["simonsays.name"] = "Саймон говорит",
    ["simonsays.desc"] = "Игроки должны следовать за цветами, показанными на экранах, последний оставшийся игрок - победитель.",
    ["simonsays.tip"] = "Чтобы приостановить игру, используйте клавишу перезагрузки (R)",
    ["simonsays.sizex"] = "Ширина",
    ["simonsays.sizex.desc"] = "Количество платформ, которые будут созданы в ширину в игре",
    ["simonsays.sizey"] = "Длина",
    ["simonsays.sizey.desc"] = "Количество платформ, которые будут созданы в длину в игре",
    ["simonsays.offset"] = "Расстояние",
    ["simonsays.offset.desc"] = "Расстояние разделения, которое будет между каждой платформой",
    ["simonsays.timereaction"] = "Время реакции",
    ["simonsays.timereaction.desc"] = "Время, которое игроки имеют для реакции, прежде чем платформа исчезнет",
    ["simonsays.substracttimereaction"] = "Быстрее время реакции",
    ["simonsays.substracttimereaction.desc"] = "На сколько будет уменьшено время реакции за раунд",
    ["simonsays.delay"] = "Время за раунд",
    ["simonsays.delay.desc"] = "Время до полного исчезновения платформы (Это время зависит от 'Вычесть время')",
    ["simonsays.substracttime"] = "Быстрые раунды",
    ["simonsays.substracttime.desc"] = "Сколько секунд сделают игру быстрее за раунд",
    ["simonsays.height"] = "Высота",
    ["simonsays.height.desc"] = "Высота, на которой будет создана игра",
    ["simonsays.amountcolors"] = "Количество цветов",
    ["simonsays.amountcolors.desc"] = "Количество цветов, которые будут использоваться в игре",
    ["simonsays.samecolors"] = "Те же цвета",
    ["simonsays.samecolors.desc"] = "Активируя это, цвета останутся теми же для каждого раунда",

    -- Ruleta rusa
    ["russianroulette.name"] = "Русская рулетка",
    ["russianroulette.desc"] = "Мини-игра, состоящая из удачи, у игроков есть 2 варианта - выстрелить или пропустить, последний оставшийся игрок - победитель.",
    ["russianroulette.tip"] = "Игроки получают оружие, когда наступает их очередь стрелять.",
    ["russianroulette.decisiontime"] = "Время принятия решения",
    ["russianroulette.decisiontime.desc"] = "Время, которое игроки имеют для принятия решения, стрелять или пропустить (Только если время принятия решения активировано)",
    ["russianroulette.magazinesize"] = "Размер магазина",
    ["russianroulette.magazinesize.desc"] = "Сколько пуль будет в магазине оружия",
    ["russianroulette.resetonfire"] = "Сброс при выстреле",
    ["russianroulette.resetonfire.desc"] = "Когда игрок стреляет из оружия, магазин изменит пулю, где находится оружие, и позиция будет сброшена",
    ["russianroulette.header.bots"] = "Боты",
    ["russianroulette.bots"] = "Количество ботов",
    ["russianroulette.bots.desc"] = "Сколько ботов будет в игре",
    ["russianroulette.hud.primaryattack"] = "Проверьте свою удачу, выстрелив из оружия",
    ["russianroulette.hud.secondaryattack"] = "Не рискуя и пропуская свою очередь",
    ["russianroulette.hud.cantskip"] = "Вы не можете пропустить свою очередь",

    -- Box Game
    ["boxgame.name"] = "Ящики",
    ["boxgame.desc"] = "Игра на ящиках состоит в том, чтобы игроки избегали быть раздавленными ящиками, последний оставшийся игрок - победитель.",
    ["boxgame.tip"] = "Ящики убивают только тогда, когда они красные, игроки умирают сразу, как только касаются их.",
    ["boxgame.delaybetweendrops"] = "Время между падающими ящиками",
    ["boxgame.delaybetweendrops.desc"] = "Сколько времени пройдет, прежде чем ящики появятся между каждым раундом.",
    ["boxgame.dropdelay"] = "Время падения",
    ["boxgame.dropdelay.desc"] = "Сколько времени пройдет, прежде чем ящики упадут.",
    ["boxgame.dropreaction"] = "Время реакции",
    ["boxgame.dropreaction.desc"] = "Сколько времени (в секундах) игроки имеют для реакции на ящики.",
    ["boxgame.startboxes"] = "Начальные ящики",
    ["boxgame.startboxes.desc"] = "Количество ящиков, которые упадут в начале игры.",
    ["boxgame.maxboxes"] = "Максимальные ящики",
    ["boxgame.maxboxes.desc"] = "Максимальное количество ящиков, которые упадут в игре. (Связано с количеством ящиков, которые будут увеличиваться за раунд)",
    ["boxgame.addmoreboxes"] = "Добавить ящики",
    ["boxgame.addmoreboxes.desc"] = "Количество ящиков, которые будут добавлены за раунд.",
    ["boxgame.sizex"] = "Ширина",
    ["boxgame.sizex.desc"] = "Количество платформ, которые будут созданы в ширину в игре",
    ["boxgame.sizey"] = "Длина",
    ["boxgame.sizey.desc"] = "Количество платформ, которые будут созданы в длину в игре",
    ["boxgame.offset"] = "Расстояние",
    ["boxgame.offset.desc"] = "Расстояние разделения, которое будет между каждой платформой",
    ["boxgame.height"] = "Высота",
    ["boxgame.height.desc"] = "Высота, на которой будет создана игра",

    -- Deathmatch
    ["deathmatch.name"] = "Дуэль",
    ["deathmatch.desc"] = "Мини-игра дуэли, цель - убить других игроков, игрок с наибольшим количеством смертей - победитель.",
    ["deathmatch.tip"] = "Чтобы приостановить игру, используйте клавишу перезагрузки (R)",
    ["deathmatch.insufficientspawns"] = "Вам нужно как минимум %s точек возрождения, чтобы начать игру",
    ["deathmatch.leaderboard"] = "Таблица лидеров",
    ["deathmatch.leaderboard.andmore"] = "и еще %str",
    ["deathmatch.tall"] = "Высота",
    ["deathmatch.tall.desc"] = "Как высоко будет таблица лидеров",
    ["deathmatch.wide"] = "Ширина",
    ["deathmatch.wide.desc"] = "Как широко будет таблица лидеров",
    ["deathmatch.heightoffset"] = "Высота",
    ["deathmatch.heightoffset.desc"] = "Высота над землей, на которой появится таблица лидеров",
    ["deathmatch.angleoffset"] = "Направление",
    ["deathmatch.angleoffset.desc"] = "В каком направлении будет смотреть таблица лидеров",
    ["deathmatch.winbytime"] = "Победа по времени",
    ["deathmatch.winbytime.desc"] = "Когда активно, игрок с наибольшим количеством смертей в конце времени будет победителем.\nКогда отключено, игрок, который достигнет количества смертей, будет победителем.",
    ["deathmatch.time"] = "Время",
    ["deathmatch.time.desc"] = "Сколько времени будет длиться игра",
    ["deathmatch.killstowin"] = "Убийства для победы",
    ["deathmatch.killstowin.desc"] = "Количество смертей, необходимых для победы в игре (Работает только если 'Победа по времени' отключена)",
    ["deathmatch.falldamage"] = "Урон от падения",
    ["deathmatch.falldamage.desc"] = "Игроки получают урон от падения",
    ["deathmatch.respawntime"] = "Время возрождения",
    ["deathmatch.respawntime.desc"] = "Время, которое игроку потребуется, чтобы возродиться",
    ["deathmatch.respawnprotection"] = "Защита при возрождении",
    ["deathmatch.respawnprotection.desc"] = "Время, в течение которого игрок будет защищен при возрождении",
    ["deathmatch.entitysettings"] = "Сущности",
    ["deathmatch.spawnentitytype"] = "Тип сущности",
    ["deathmatch.spawnentitytype.desc"] = "Тип сущности, которую вы собираетесь создать для мини-игры",
    ["deathmatch.spawnentitytypeoffset"] = "Высота",
    ["deathmatch.spawnentitytypeoffset.desc"] = "Высота над землей, на которой появится сущность",
    ["deathmatch.spawnpointrotation"] = "Угол сущности",
    ["deathmatch.spawnpointrotation.desc"] = "В каком направлении будет смотреть сущность, когда она появится",
    ["deathmatch.health"] = "Здоровье",
    ["deathmatch.health.desc"] = "Количество жизни, которое игроки восстановят, когда они соберут здоровье",
    ["deathmatch.healthrespawn"] = "Здоровье (Время возрождения)",
    ["deathmatch.healthrespawn.desc"] = "Время, которое потребуется для восстановления здоровья",
    ["deathmatch.armor"] = "Броня",
    ["deathmatch.armor.desc"] = "Количество брони, которое игроки восстановят, когда они соберут броню",
    ["deathmatch.armorrespawn"] = "Броня (Время возрождения)",
    ["deathmatch.armorrespawn.desc"] = "Время, которое потребуется для восстановления брони",
    ["deathmatch.ammo"] = "Боеприпасы",
    ["deathmatch.ammo.desc"] = "Количество боеприпасов, которые игроки восстановят, когда они соберут боеприпасы",
    ["deathmatch.ammorespawn"] = "Боеприпасы (Время возрождения)",
    ["deathmatch.ammorespawn.desc"] = "Время, которое потребуется для восстановления боеприпасов",
    ["deathmatch.weaponskit"] = "Набор оружия",
    ["deathmatch.weaponskit.desc"] = "Набор оружия, который появится в игре, чтобы добавить категории и оружие, отредактируйте свой файл \"configuration.lua\"",
}