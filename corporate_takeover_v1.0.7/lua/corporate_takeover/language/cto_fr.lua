local lang = {}

lang.name = "Français"
lang.short = "fr"

// Made by https://www.gmodstore.com/users/tomkez

lang.lang = {
	// General
	err = "Quelque chose s'est mal passé. Veuillez réessayer !",
	no_space = "Il n'y a pas assez de place !",
	max = "Max",
	level = "Niveau",
	xp = "XP",
	energy = "Énergie",
	wage = "Salaire",
	age = "Age",
	earnings = "Gains",
	profit = "Profit",

	cto_missing_admin = "Vous avez besoin d'être administrateur pour faire ceci !",
	cto_missing_donator = "Vous avez besoin d'être VIP pour faire ceci !",

	key_place_desk = "Clic Gauche : Placer le bureau",
	key_cancel_desk = "Clic Droit : Annuler",

	// Permissions
	not_yours = "Ce n'est pas votre carton !",
	not_your_desk = "Ce bureau ne vous appartient pas !",

	// Corporation
	corp_exists = "Vous avez déjà une entreprise !",
	create_corp = "Créer une entreprise",
	create_corp_button = "Créer l'entreprise (%price)", -- %price
	corp_name = "Nom de l'entreprise",
	old_corp = "Ceci appartient à votre ancienne entreprise !",
	placeholder_name = "Mon entreprise",

	corp_created = "Vous avez créé votre entreprise '%name' avec succès !", -- %name
	no_money_to_create_corp = "Vous n'avez pas %money pour créer une entreprise !", -- %money
	corp_insufficient_level = "Votre entreprise n'a pas encore atteint le niveau %level !", -- %level
	corpname_too_long = "Le nom de votre entreprise ne doit pas faire plus de 30 caractères !",
	corpname_empty = "Votre entreprise doit avoir un nom !",
	corpname_too_short = "Le nom de votre entreprise doit faire 5 caractères minimum !",
	corpname_default = "Veuillez utiliser un nom différent pour votre entreprise !",

	corp_reached_level = "%name a atteint le niveau %level",

	// Desks related
	desk_limit = "Vous avez atteint la limite de ce bureau !",
	desk_no_money = "Votre entreprise n'a pas assez d'argent pour payer ce bureau !",
	deskbuilder_limit = "Vous avez atteint la limite de cartons !",
	dismantle = "Supprimer le bureau",
	dismantle_vault = "Supprimer le coffre fort",
	cant_sell = "Vous ne pouvez pas vendre ce bureau !",
	desk_sold = "Vous avez vendu %name pour %price !",
	build_desk = "Construire le bureau",
	sell_desk = "Vendre le bureau",

	// Coffee
	coffee_limit = "Vous avez atteint la limite de cafés !",
	coffee_no_money = "Votre entreprise n'a pas assez d'argent pour payer ce café !",

	coffee_black = "Café noir",
	coffee_black_sugar = "Café noir avec sucre",
	coffee_bean = "Café en grains",
	coffee_bean_sugar = "Café en grains avec sucre",

	// Money deposit/withdraw
	withdraw_money = "Retirer de l'argent",
	money_amount = "Montant de l'argent",
	deposit_money = "Déposer de l'argent",
	withdrew_money = "Vous avez retiré %amount !",
	deposited_money = "Vous avez déposé %amount !",
	vault_expanded = "Vous avez amélioré votre coffre fort afin qu'il puisse contenir %amount pour %price !",
	no_money = "Vous n'avez pas assez d'argent dans le coffre fort de votre entreprise !",
	no_money_user = "Vous n'avez pas assez d'argent !",
	money_too_low = "Le montant sélectionné ne doit pas être égal ou en dessous de 0 !",

	// Vault
	open_vault = "Ouvrir le coffre fort",
	close_vault = "Fermer le coffre fort",
	build_vault = "Construire le coffre fort",
	sell_vault = "Vendre le coffre fort",
	upgrade_vault = "Améliorer le coffre fort",

	// workers
	select_worker = "Sélectionner l'employé",
	hire_worker = "Recruter %s",
	worker_hired = "Vous avez recruté %name comme nouvel employé !",
	worker_wage_unpayable = "Votre entreprise n'a pas assez d'argent pour payer %name !",
	too_tired = "%name est trop fatigué pour travailler !",
	select_worker_first = "Vous devez sélectionner un employé !",
	fire_worker = "Virer l'employé",
	worker_fired = "Vous avez viré %name",
	asleep = "Endormi(e) - [%key] pour réveiller",
	new_workers_in = "Nouveaux employés disponibles dans",

	// Destruction
	corp_rebellion = "Vos employés ont fait une rébellion et ont tout brulé !",
	corp_bankrupt = "Vos employés partent parce que vous ne pouvez pas les payer !",
	corp_lost = "Votre bureau d'entreprise a été détruit. Votre entreprise a fermé :(",

	// Desk names
	corporate_desk = "Bureau d'Entreprise",
	basic_worker_desk = "Bureau d'Employé Basique",
	intermediate_worker_desk = "Bureau d'Employé Intermédiaire",
	advanced_worker_desk = "Bureau d'Employé Avancé",
	ultimate_worker_desk = "Bureau d'Employé Ultime",
	secretary_desk = "Bureau de Secrétaire",
	research_desk = "Bureau de Recherche",
	vault = "Coffre Fort d'Entreprise",

	//Researches
	research_waiting = "En attente",
	research_description = "Ici il y aura la description de la recherche",
	wakeup_employees = "Réveiller les employés",
	start_research = "Commencer la recherche",
	select_research_first = "Vous devez sélectionner une recherche avant de faire ceci !",
	research_open = "Ouvrez une recherche pour voir sa description !",
	research_finished = "Vous avez fini la recherche de %name",

	research_in_progress = "Il y a déjà une recherche en cours !",
	research_no_money = "Vous n'avez pas assez d'argent pour commencer cette recherche !",
	research_needed = "Vous avez besoin de rechercher %name avant de faire cela !",
	research_started = "Vous avez commencé la recherche de %name",

	research_efficiency = "Recherche Rapide",
	research_price_drop = "Négociateur",
	xp_worker_1 = "Employés Intelligents I",
	xp_worker_2 = "Employés Intelligents II",
	xp_corp_1 = "Entreprise Intelligente I",
	xp_corp_2 = "Entreprise Intelligente II",
	research_wage_1 = "Employés peu chers I",
	research_wage_2 = "Employés peu chers II",
	research_wage_3 = "Employés peu chers III",
	automatic_coffee_self = "Serviteur Egoïste",
	automatic_coffee = "Serviteur",
	wakeup_employees_research = "Réveiller",

	research_efficiency_desc = "Toutes les recherches iront 10% plus vite !",
	research_price_drop_desc = "Toutes les recherches coûteront 10% moins cher !",
	xp_worker_1_desc = "Vos employés gagneront 10% d'XP en plus !",
	xp_worker_2_desc = "Vos employés gagneront 10% d'XP en plus !",
	xp_corp_1_desc = "Votre entreprise gagnera 10% d'XP en plus !",
	xp_corp_2_desc = "Votre entreprise gagnera 10% d'XP en plus !",
	research_wage_1_desc = "Le salaire de vos employés sera réduit de 10%.",
	research_wage_2_desc = "Le salaire de vos employés sera réduit de 10%.",
	research_wage_3_desc = "Le salaire de vos employés sera réduit de 10%.",

	wakeup_employees_desc = "Si le niveau d'energie de votre bureau de secrétaire est suffisant, il sera capable de reveiller tous les employés.",
	automatic_coffee_desc = "Votre bureau de secrétaire sera capable de redonner de l'energie à tous les employés (sauf à lui même)",
	automatic_coffee_self_desc = "Votre bureau de secrétaire sera capable de se redonner de l'energie !",
}

Corporate_Takeover:RegisterLang(lang.name, lang.short, lang.lang)
