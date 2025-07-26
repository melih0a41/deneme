local lang = {}

lang.name = "Português"
lang.short = "pt"

// Made by https://www.gmodstore.com/users/76561198075216760 (StoRM)

lang.lang = {
	// General
	err = "Algo deu errado, por favor tente novamente!",
	no_space = "Não tem espaço suficiente!",
	max = "Max.",
	level = "Nível",
	xp = "XP",
	energy = "Energia",
	wage = "Salário",
	age = "Idade",
	earnings = "Ganhos",
	profit = "Lucro",

	cto_missing_admin = "Você precisa ser Admin para fazer isso!",
	cto_missing_donator = "Você precisa ser VIP para fazer isso!",

	key_place_desk = "LMB: Colocar Mesa",
	key_cancel_desk = "RMB: Cancelar",

	// Permissions
	not_yours = "Esse não é o seu deskbuilder!",
	not_your_desk = "Isso não pertence a você!",

	// Corporation
	corp_exists = "Você já tem uma empresa. Você não quer cuidar dela primeiro?",
	create_corp = "Criar Empresa",
	create_corp_button = "Criar Empresa (%price)", -- %price
	corp_name = "Nome da Empresa",
	old_corp = "Isso pertence a sua empresa antiga!",
	placeholder_name = "Minha Empresa",

	corp_created = "Você fundou a '%name' com sucesso!", -- %name
	no_money_to_create_corp = "Você não tem %money para criar a empresa!", -- %money
	corp_insufficient_level = "Sua empresa ainda não está no nível %level!", -- %level
	corpname_too_long = "O nome da sua empresa não pode ter mais de 30 caracteres!",
	corpname_empty = "O nome da sua empresa não pode estar vazio!",
	corpname_too_short = "O nome da sua empresa deve ter pelo menos 5 caracteres!",
	corpname_default = "Por favor, use um nome diferente para sua empresa!",

	corp_reached_level = "%name alcançou o nível %level",

	// Desks related
	desk_limit = "Você chegou no limite desta mesa!",
	desk_no_money = "Sua empresa não tem o dinheiro suficiente para comprar esta mesa!",
	deskbuilder_limit = "Você chegou no limite de deskbuilders!",
	dismantle = "Desmontar mesa",
	dismantle_vault = "Desmontar cofre",
	cant_sell = "Você não pode vender essa mesa!",
	desk_sold = "Você vendeu %name por %price",
	sell_desk = "Vender mesa",
	build_desk = "Construir mesa",

	// Coffee
	coffee_limit = "Você chegou no limite de café!",
	coffee_no_money = "Sua empresa não tem dinheiro o suficiente para comprar este café!",

	coffee_black = "Café preto",
	coffee_black_sugar = "Café preto com açúcar",
	coffee_bean = "Café preto premium",
	coffee_bean_sugar = "Café preto premium com açúcar",

	// Money deposit/withdraw
	withdraw_money = "Sacar dinheiro",
	money_amount = "Quantia de dinheiro",
	deposit_money = "Depositar dinheiro",
	withdrew_money = "Você sacou %amount",
	deposited_money = "Você depositou %amount",
	vault_expanded = "Você expandiu seu cofre para segurar %amount por %price",
	no_money = "Sua empresa não tem dinheiro suficiente no cofre!",
	no_money_user = "Você não tem dinheiro suficiente!",
	money_too_low = "A quantidade selecionada não pode ser menor ou igual a 0!",

	// Vault
	open_vault = "Abrir cofre",
	close_vault = "Fechar cofre",
	sell_vault = "Vender cofre",
	build_vault = "Construir cofre",
	upgrade_vault = "Melhorar cofre",

	// workers
	select_worker = "Selecionar empregado",
	hire_worker = "Contratar %s",
	worker_hired = "Você contratou %name como seu novo empregado!",
	worker_wage_unpayable = "Sua empresa não tem dinheiro suficiente para pagar %name",
	too_tired = "%name está muito cansado para trabalhar!",
	select_worker_first = "Você precisa primeiro selecionar um empregado!",
	fire_worker = "Demitir empregado",
	worker_fired = "Você demitiu %name",
	asleep = "Dormindo - [%key] para acordar",
	new_workers_in = "Novos empregados chegaram!",

	// Destruction
	corp_rebellion = "Seus empregados começaram uma rebelião e destruíram tudo!",
	corp_bankrupt = "Seus empregados se demitiram por falta de pagamento!",
	corp_lost = "Sua mesa corporativa foi destruída! Sua empresa foi perdida! :(",

	// Desk names
	corporate_desk = "Mesa Corporativa",
	basic_worker_desk = "Mesa Básica de Empregado",
	intermediate_worker_desk = "Mesa Intermediária de Empregado",
	advanced_worker_desk = "Mesa Avançada de Empregado",
	ultimate_worker_desk = "Mesa Suprema de Empregado",
	secretary_desk = "Mesa de Secretária",
	research_desk = "Mesa de Pesquisa",
	vault = "Cofre Corporativo",

	//Researches
	research_waiting = "Aguardando",
	research_description = "Aqui irá aparecer uma descrição do que você está pesquisando.",
	wakeup_employees = "Acordar empregados",
	start_research = "Começar pesquisa",
	select_research_first = "Você deve selecionar uma opção de pesquisa primeiro!",
	research_open = "Escolha uma opção de pesquisa para ver a descrição!",
	research_finished = "Você acabou de pesquisar %name",

	research_in_progress = "Já tem uma pesquisa em progresso!",
	research_no_money = "Você não tem dinheiro suficiente para iniciar essa pesquisa!",
	research_needed = "Você precisa pesquisar %name primeiro!",
	research_started = "Você começou a pesquisar %name",

	research_efficiency = "Pesquisador Rápido",
	research_price_drop = "Negociador",
	xp_worker_1 = "Empregado Inteligente I",
	xp_worker_2 = "Empregado Inteligente II",
	xp_corp_1 = "Empresa Inteligente I",
	xp_corp_2 = "Empresa Inteligente II",
	research_wage_1 = "Empregado Barato I",
	research_wage_2 = "Empregado Barato II",
	research_wage_3 = "Empregado Barato III",
	automatic_coffee_self = "Assistente Autônoma",
	automatic_coffee = "Assistente",
	wakeup_employees_research = "Acorda!",

	research_efficiency_desc = "Toda pesquisa será 10% mais rápida.",
	research_price_drop_desc = "Toda pesquisa será 10% mais barata.",
	xp_worker_1_desc = "Todos os empregados ganham 10% a mais de XP.",
	xp_worker_2_desc = "Todos os empregados ganham 10% a mais de XP.",
	xp_corp_1_desc = "Sua empresa ganha 25% a mais de XP.",
	xp_corp_2_desc = "Sua empresa ganha 10% a mais de XP.",
	research_wage_1_desc = "O salário dos seus empregados será diminuído em 10%.",
	research_wage_2_desc = "O salário dos seus empregados será diminuído em 10% adicionais.",
	research_wage_3_desc = "O salário dos seus empregados será diminuído em 10% adicionais.",

	wakeup_employees_desc = "Sua secretária será capaz de acordar todos os empregados dormindo assim que o nível de energia deles for suficiente.",
	automatic_coffee_desc = "Sua secretária será capaz de repor a energia de todos os empregados (exceto ela mesma).",
	automatic_coffee_self_desc = "Sua secretária será capaz de repor a energia dela mesma.",
}

Corporate_Takeover:RegisterLang(lang.name, lang.short, lang.lang)