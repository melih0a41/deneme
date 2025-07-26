local lang = {}

lang.name = "Deutsch"
lang.short = "de"

lang.lang = {
	// Allgemein
	err = "Etwas ist schiefgelaufen. Bitte versuche es erneut!",
	no_space = "Es gibt nicht genügend Platz!",
	max = "Max.",
	level = "Level",
	xp = "XP",
	energy = "Energie",
	wage = "Lohn",
	age = "Alter",
	earnings = "Einkommen",
	profit = "Profit",

	cto_missing_admin = "Du musst Admin sein, um dies tun zu können!",
	cto_missing_donator = "Du musst VIP sein, um dies tun zu können!",

	key_place_desk = "LMB: Schreibtisch platzieren",
	key_cancel_desk = "RMB: Abbrechen",

	// Berechtigungen
	not_yours = "Das ist nicht dein Schreibtischbauer!",
	not_your_desk = "Dies gehört dir nicht!",

	// Corporation
	corp_exists = "Du hast bereits eine Corporation. Willst du dich nicht darum kümmern?",
	create_corp = "Firma gründen",
	create_corp_button = "Firma gründen (%price)", -- %price
	corp_name = "Firmenname",
	old_corp = "Das gehört zu deiner alten Corporation!",
	placeholder_name = "Meine Firma",

	corp_created = "Du hast deine Firma '%name' erfolgreich gegründet", -- %name
	no_money_to_create_corp = "Du hast nicht genug Geld (%money), um eine Firma zu gründen!", -- %money
	corp_insufficient_level = "Deine Firma hat noch nicht Level %level erreicht!", -- %level
	corpname_too_long = "Der Firmenname darf 30 Zeichen nicht überschreiten!",
	corpname_empty = "Der Firmenname darf nicht leer sein!",
	corpname_too_short = "Der Firmenname muss mindestens 5 Zeichen lang sein!",
	corpname_default = "Bitte benutze einen anderen Namen für deine Firma!",

	corp_reached_level = "%name hat Level %level erreicht",

	// Schreibtische
	desk_limit = "Du hast das Limit dieses Schreibtisches erreicht!",
	desk_no_money = "Deine Firma hat nicht genug Geld, um diesen Schreibtisch zu kaufen!",
	deskbuilder_limit = "Du hast das Limit von Schreibtischbauern erreicht!",
	dismantle = "Schreibtisch abbauen",
	dismantle_vault = "Vault abbauen",
	cant_sell = "Du kannst diesen Schreibtisch nicht verkaufen!",
	desk_sold = "Du hast %name für %price verkauft",
	sell_desk = "Schreibtisch verkaufen",
	build_desk = "Schreibtisch bauen",

	// Kaffee
	coffee_limit = "Du hast das Limit von Kaffee erreicht!",
	coffee_no_money = "Deine Firma hat nicht genug Geld, um diesen Kaffee zu kaufen!",

	coffee_black = "Schwarzer Kaffee",
	coffee_black_sugar = "Schwarzer Kaffee mit Zucker",
	coffee_bean = "Schwarzer Bohnenkaffee",
	coffee_bean_sugar = "Schwarzer Bohnenkaffee mit Zucker",

	// Geld einzahlen/abheben
	withdraw_money = "Geld abheben",
	money_amount = "Menge an Geld",
	deposit_money = "Geld einzahlen",
	withdrew_money = "Du hast %amount abgehoben",
	deposited_money = "Du hast %amount eingezahlt",
	vault_expanded = "Du hast deinen Vault auf %amount erweitert für %price",
	no_money = "Du hast nicht genug Geld in deinem Firmenvault!",
	no_money_user = "Du hast nicht genug Geld!",
	money_too_low = "Der ausgewählte Betrag darf nicht gleich oder unter 0 sein!",

	// Vault
	open_vault = "Tresor öffnen",
	close_vault = "Tresor schließen",
	sell_desk = "Tresor verkaufen",
	build_desk = "Tresor bauen",
	upgrade_vault = "Tresor verbessern",

	// Arbeiter
	select_worker = "Arbeiter auswählen",
	hire_worker = "%s anstellen",
	worker_hired = "Du hast %name als neuen Arbeiter eingestellt!",
	worker_wage_unpayable = "Dein Unternehmen hat nicht genug Geld, um %name zu bezahlen",
	too_tired = "%name ist zu müde zum Arbeiten!",
	select_worker_first = "Du musst zuerst einen Arbeiter auswählen!",
	fire_worker = "Arbeiter entlassen",
	worker_fired = "Du hast %name entlassen",
	asleep = "Eingeschlafen - [%key] zum Aufwecken",
	new_workers_in = "Neue Arbeiter in",

	// Zerstörung
	corp_rebellion = "Deine Mitarbeiter haben eine Rebellion gestartet und alles niedergebrannt!",
	corp_bankrupt = "Deine Mitarbeiter haben gekündigt, weil du sie nicht bezahlen kannst!",
	corp_lost = "Dein Corporate Desk wurde zerstört. Dein Unternehmen ist verloren :(",

	// Desk-Namen
	corporate_desk = "Firmenschreibtisch",
	basic_worker_desk = "Standart Schreibtisch",
	intermediate_worker_desk = "Verbesserter Schreibtisch",
	advanced_worker_desk = "Verbesserter Schreibtisch",
	ultimate_worker_desk = "Ultimate Schreibtisch",
	secretary_desk = "Sekretärtisch",
	research_desk = "Forschungstisch",
	vault = "Firmentresor",

	// Forschungen
	research_waiting = "Warten",
	research_description = "Hier steht eine Beschreibung der jeweiligen Forschung",
	wakeup_employees = "Mitarbeiter wecken",
	start_research = "Forschung starten",
	select_research_first = "Du musst zuerst eine Forschung auswählen!",
	research_open = "Klicke auf eine Forschung, um ihre Beschreibung zu sehen!",
	research_finished = "Du hast %name erforscht!",

	research_in_progress = "Es läuft bereits eine Forschung!",
	research_no_money = "Du hast nicht genug Geld, um diese Forschung zu starten!",
	research_needed = "Du musst zuerst %name erforschen!",
	research_started = "Du hast mit der Erforschung von %name begonnen",

	research_efficiency = "Schnelle Wissenschaft",
	research_price_drop = "Verhandler",
	xp_worker_1 = "Intelligenter Arbeiter I",
	xp_worker_2 = "Intelligenter Arbeiter II",
	xp_corp_1 = "Intelligentes Unternehmen I",
	xp_corp_2 = "Intelligentes Unternehmen II",
	research_wage_1 = "Günstige Arbeiter I",
	research_wage_2 = "Günstige Arbeiter II",
	research_wage_3 = "Günstige Arbeitskräfte III",
	automatic_coffee_self = "Selbstversorger",
	automatic_coffee = "Diener",
	wakeup_employees_research = "Aufwachen!",

	research_efficiency_desc = "Alle Forschungen werden 10% schneller durchgeführt.",
	research_price_drop_desc = "Alle Forschungen kosten 10% weniger.",
	xp_worker_1_desc = "Deine Arbeiter erhalten 10% mehr Erfahrungspunkte.",
	xp_worker_2_desc = "Deine Arbeiter erhalten 10% mehr Erfahrungspunkte.",
	xp_corp_1_desc = "Deine Firma erhält 25% mehr Erfahrungspunkte.",
	xp_corp_2_desc = "Deine Firma erhält 10% mehr Erfahrungspunkte.",
	research_wage_1_desc = "Der Lohn Ihrer Arbeiter wird um 10% gesenkt.",
	research_wage_2_desc = "Der Lohn Ihrer Arbeiter wird um weitere 10% gesenkt.",
	research_wage_3_desc = "Der Lohn Ihrer Arbeiter wird um weitere 10% gesenkt.",

	wakeup_employees_desc = "Dein Sekretär wird in der Lage sein, alle schlafenden Arbeiter aufzuwecken, sobald ihr Energielevel ausreichend ist.",
	automatic_coffee_desc = "Dein Sekretär wird in der Lage sein, die Energie aller Arbeiter (außer sich selbst) aufzufüllen.",
	automatic_coffee_self_desc = "Dein Sekretär wird in der Lage sein, seine eigene Energie aufzufüllen.",
}

Corporate_Takeover:RegisterLang(lang.name, lang.short, lang.lang)