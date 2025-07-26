local lang = {}

lang.name = "English"
lang.short = "en"

lang.lang = {
	// General
	err = "Something went wrong. Please try again!",
	no_space = "There is not enough space!",
	max = "Max.",
	level = "Level",
	xp = "XP",
	energy = "Energy",
	wage = "Wage",
	age = "Age",
	earnings = "Earnings",
	profit = "Profit",

	cto_missing_admin = "You need to be admin to do this!",
	cto_missing_donator = "You need to be VIP to do this!",

	key_place_desk = "LMB: Place desk",
	key_cancel_desk = "RMB: Cancel",

	// Permissions
	not_yours = "This is not your deskbuilder!",
	not_your_desk = "This does not belong to you!",

	// Corporation
	corp_exists = "You already have a corporation. Don't you want to take care of it?",
	create_corp = "Create Corporation",
	create_corp_button = "Create Corporation (%price)", -- %price
	corp_name = "Company name",
	old_corp = "This belongs to your old Corporation!",
	placeholder_name = "My Company",

	corp_created = "You successfully created your company '%name'", -- %name
	no_money_to_create_corp = "You don't have %money to create a company!", -- %money
	corp_insufficient_level = "Your corporation has not yet passed level %level!", -- %level
	corpname_too_long = "Your corporation name must not exceed the limit of 30 characters!",
	corpname_empty = "Your corporation name cant be empty!",
	corpname_too_short = "Your corporation name must be at least 5 characters long!",
	corpname_default = "Please use a different name for your corporation!",

	corp_reached_level = "%name reached level %level",

	// Desks related
	desk_limit = "You have reached the limit of this desk!",
	desk_no_money = "Your corporation does not have enough money to buy this desk!",
	deskbuilder_limit = "You have reached the limit of deskbuilders!",
	dismantle = "Dismantle desk",
	dismantle_vault = "Dismantle vault",
	cant_sell = "You can't sell this desk!",
	desk_sold = "You sold %name for %price",
	sell_desk = "Sell desk",
	build_desk = "Build desk",

	// Coffee
	coffee_limit = "You have reached the limit of coffee!",
	coffee_no_money = "Your corporation does not have enough money to buy this coffee!",

	coffee_black = "Black coffee",
	coffee_black_sugar = "Black coffee with sugar",
	coffee_bean = "Black bean coffee",
	coffee_bean_sugar = "Black bean coffee with sugar",

	// Money deposit/withdraw
	withdraw_money = "Withdraw money",
	money_amount = "Amount of money",
	deposit_money = "Deposit money",
	withdrew_money = "You withdrew %amount",
	deposited_money = "You deposited %amount",
	vault_expanded = "You expanded your vault to hold %amount for %price",
	no_money = "You dont have enough money in your company vault!",
	no_money_user = "You dont have enough money!",
	money_too_low = "Your selected amount must not be equal to or below 0!",

	// Vault
	open_vault = "Open vault",
	close_vault = "Close vault",
	sell_vault = "Sell vault",
	build_vault = "Build vault",
	upgrade_vault = "Upgrade vault",

	// workers
	select_worker = "Select worker",
	hire_worker = "Hire %s",
	worker_hired = "You hired %name as a new worker!",
	worker_wage_unpayable = "Your company does not have enough money to pay %name",
	too_tired = "%name is too tired to work!",
	select_worker_first = "You must select a worker first!",
	fire_worker = "Fire worker",
	worker_fired = "You fired %name",
	asleep = "Asleep - [%key] to wake up",
	new_workers_in = "New workers in",

	// Destruction
	corp_rebellion = "Your employees started a rebellion and burnt everything down!",
	corp_bankrupt = "Your employees quit because you can't pay them!",
	corp_lost = "Your corporate desk got destroyed. Your Company is lost :(",

	// Desk names
	corporate_desk = "Corporate Desk",
	basic_worker_desk = "Basic Worker Desk",
	intermediate_worker_desk = "Intermediate Worker Desk",
	advanced_worker_desk = "Advanced Worker Desk",
	ultimate_worker_desk = "Ultimate Worker Desk",
	secretary_desk = "Secretary Desk",
	research_desk = "Research Desk",
	vault = "Corporate vault",

	//Researches
	research_waiting = "Waiting",
	research_description = "Here will be a description of the research",
	wakeup_employees = "Wakeup employees",
	start_research = "Start research",
	select_research_first = "You must select a research option first!",
	research_open = "Open a research option to see it's description!",
	research_finished = "You finished researching %name",

	research_in_progress = "There is already a research in progress!",
	research_no_money = "You don't have enough money to start this research!",
	research_needed = "You need to research %name first!",
	research_started = "You started researching %name",

	research_efficiency = "Fast Researcher",
	research_price_drop = "Negotiator",
	xp_worker_1 = "Smart worker I",
	xp_worker_2 = "Smart worker II",
	xp_corp_1 = "Smart Company I",
	xp_corp_2 = "Smart Company II",
	research_wage_1 = "Cheap workers I",
	research_wage_2 = "Cheap workers II",
	research_wage_3 = "Cheap workers III",
	automatic_coffee_self = "Selfserving Servant",
	automatic_coffee = "Servant",
	wakeup_employees_research = "Wake up!",

	research_efficiency_desc = "All researches will be 10% quicker",
	research_price_drop_desc = "All researches will cost 10% less",
	xp_worker_1_desc = "Your workers will gain 10% more XP.",
	xp_worker_2_desc = "Your workers will gain 10% more XP.",
	xp_corp_1_desc = "Your company will gain 25% more XP.",
	xp_corp_2_desc = "Your company will gain 10% more XP.",
	research_wage_1_desc = "The wage of your workers will be dropped by 10%.",
	research_wage_2_desc = "The wage of your workers will be dropped by an additional 10%.",
	research_wage_3_desc = "The wage of your workers will be dropped by an additional 10%.",

	wakeup_employees_desc = "Your secretary desk will be able to wake up all sleeping workers as soon as their energy level is sufficient.",
	automatic_coffee_desc = "Your secretary desk will be able to replenish the energy of all workers (except itself).",
	automatic_coffee_self_desc = "Your secretary desk will be able to replenish the energy of itself.",
}

Corporate_Takeover:RegisterLang(lang.name, lang.short, lang.lang)