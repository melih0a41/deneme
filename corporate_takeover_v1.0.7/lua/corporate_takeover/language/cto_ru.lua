local lang = {}

lang.name = "Русский"
lang.short = "ru"

// Made by https://www.gmodstore.com/users/eysti

lang.lang = {
	// General
	err = "Что-то пошло не так. Пожалуйста, попробуйте еще раз!",
	no_space = "Недостаточно места!",
	max = "Макс.",
	xp = "Опыт",
	energy = "Энергия",
	level = "Уровень",
	wage = "Зарплата",
	age = "Возраст",
	earnings = "Доход",
	profit = "Прибыль",

	cto_missing_admin = "Вы должны быть администратором, чтобы сделать это!",
	cto_missing_donator = "Вы должны быть VIP, чтобы сделать это!",

	key_place_desk = "ЛКМ: Поставить стол",
	key_cancel_desk = "ПКМ: Отмена",

	// Permissions
	not_yours = "Это не ваш конструктор столов!",
	not_your_desk = "Это вам не принадлежит!",

	// Corporation
	corp_exists = "У вас уже есть корпорация. Не хотите позаботиться о ней?",
	create_corp = "Создать корпорацию",
	create_corp_button = "Создать корпорацию (%price)", -- %price
	corp_name = "Название компании",
	old_corp = "Это принадлежит вашей старой корпорации!",
	placeholder_name = "Моя компания",

	corp_created = "Вы успешно создали свою компанию '%name'", -- %name
	no_money_to_create_corp = "У вас нет %money для создания компании!", -- %money
	corp_insufficient_level = "Ваша корпорация еще не достигла уровня %level!", -- %level
	corpname_too_long = "Название вашей корпорации не должно превышать 30 символов!",
	corpname_empty = "Название вашей корпорации не может быть пустым!",
	corpname_too_short = "Название вашей корпорации должно содержать не менее 5 символов!",
	corpname_default = "Пожалуйста, используйте другое название для вашей корпорации!",

	corp_reached_level = "%name достигла уровня %level",

	// Desks related
	desk_limit = "Вы достигли лимита для этого стола!",
	desk_no_money = "У вашей корпорации недостаточно денег для покупки этого стола!",
	deskbuilder_limit = "Вы достигли лимита конструкторов столов!",
	dismantle = "Разобрать стол",
	dismantle_vault = "Разобрать хранилище",
	sell_desk = "Продать стол",
	cant_sell = "Вы не можете продать этот стол!",
	build_desk = "Построить стол",
	desk_sold = "Вы продали %name за %price",

	// Coffee
	coffee_limit = "Вы достигли лимита кофе!",
	coffee_no_money = "У вашей корпорации недостаточно денег для покупки этого кофе!",

	coffee_black = "Чёрный кофе",
	coffee_black_sugar = "Чёрный кофе с сахаром",
	coffee_bean = "Зерновой кофе",
	coffee_bean_sugar = "Зерновой кофе с сахаром",

	// Money deposit/withdraw
	withdraw_money = "Снять деньги",
	money_amount = "Сумма денег",
	deposit_money = "Внести деньги",
	withdrew_money = "Вы сняли %amount",
	deposited_money = "Вы внесли %amount",
	vault_expanded = "Вы расширили хранилище до %amount за %price",
	no_money = "В хранилище вашей компании недостаточно денег!",
	no_money_user = "У вас недостаточно денег!",
	money_too_low = "Выбранная вами сумма не должна быть равна или меньше 0!",

	// Vault
	open_vault = "Открыть хранилище",
	close_vault = "Закрыть хранилище",
	sell_vault = "Продать хранилище",
    build_vault = "Построить хранилище",
	upgrade_vault = "Улучшить хранилище",

	// workers
	select_worker = "Выбрать работника",
	hire_worker = "Нанять %s",
	worker_hired = "Вы наняли %name как нового работника!",
	worker_wage_unpayable = "У вашей компании недостаточно денег, чтобы заплатить %name",
	too_tired = "%name слишком устал, чтобы работать!",
	select_worker_first = "Сначала вы должны выбрать работника!",
	fire_worker = "Уволить работника",
	worker_fired = "Вы уволили %name",
	asleep = "Спит - [%key] чтобы разбудить",
	new_workers_in = "Новые работники через",

	// Destruction
	corp_rebellion = "Ваши сотрудники подняли бунт и всё сожгли!",
	corp_bankrupt = "Ваши сотрудники уволились, потому что вы не можете им платить!",
	corp_lost = "Ваш корпоративный стол уничтожен. Ваша компания потеряна :(",

	// Desk names
	corporate_desk = "Корпоративный стол",
	basic_worker_desk = "Базовый рабочий стол",
	intermediate_worker_desk = "Средний рабочий стол",
	advanced_worker_desk = "Продвинутый рабочий стол",
	ultimate_worker_desk = "Ультимативный рабочий стол",
	secretary_desk = "Стол секретаря",
	research_desk = "Исследовательский стол",
	vault = "Корпоративное хранилище",

	//Researches
	research_waiting = "В ожидании",
	research_description = "Здесь будет описание исследования",
	wakeup_employees = "Разбудить сотрудников",
	start_research = "Начать исследование",
	select_research_first = "Сначала вы должны выбрать вариант исследования!",
	research_open = "Откройте вариант исследования, чтобы увидеть его описание!",
	research_finished = "Вы завершили исследование %name",

	research_in_progress = "Исследование уже идет!",
	research_no_money = "У вас недостаточно денег, чтобы начать это исследование!",
	research_needed = "Сначала вам нужно исследовать %name!",
	research_started = "Вы начали исследование %name",

	research_efficiency = "Быстрый исследователь",
	research_price_drop = "Переговорщик",
	xp_worker_1 = "Умный работник I",
	xp_worker_2 = "Умный работник II",
	xp_corp_1 = "Умная компания I",
	xp_corp_2 = "Умная компания II",
	research_wage_1 = "Дешевые работники I",
	research_wage_2 = "Дешевые работники II",
	research_wage_3 = "Дешевые работники III",
	automatic_coffee_self = "Самообслуживающий слуга",
	automatic_coffee = "Слуга",
	wakeup_employees_research = "Разбудить сотрудников",

	research_efficiency_desc = "Все исследования будут на 10% быстрее",
	research_price_drop_desc = "Все исследования будут стоить на 10% дешевле",
	xp_worker_1_desc = "Ваши работники будут получать на 10% больше опыта.",
	xp_worker_2_desc = "Ваши работники будут получать на 10% больше опыта.",
	xp_corp_1_desc = "Ваша компания будет получать на 25% больше опыта.",
	xp_corp_2_desc = "Ваша компания будет получать на 10% больше опыта.",
	research_wage_1_desc = "Зарплата ваших работников будет снижена на 10%.",
	research_wage_2_desc = "Зарплата ваших работников будет снижена еще на 10%.",
	research_wage_3_desc = "Зарплата ваших работников будет снижена еще на 10%.",

	wakeup_employees_desc = "Ваш стол секретаря сможет будить всех спящих работников, как только их уровень энергии будет достаточным.",
	automatic_coffee_desc = "Ваш стол секретаря сможет пополнять энергию всех работников (кроме себя).",
	automatic_coffee_self_desc = "Ваш стол секретаря сможет пополнять свою собственную энергию.",
}

Corporate_Takeover:RegisterLang(lang.name, lang.short, lang.lang)