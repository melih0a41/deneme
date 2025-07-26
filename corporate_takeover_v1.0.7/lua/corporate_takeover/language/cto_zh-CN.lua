local lang = {}

lang.name = "简体中文"
lang.short = "zh-CN"

// Made by https://www.gmodstore.com/users/Quentin_Cooper

lang.lang = {
	-- General
	err = "出现致命错误，请重试尝试！", -- Something went wrong. Please try again!
	no_space = "没有足够的空间！", -- There is not enough space!
	max = "最大", -- Max.
	level = "等级", -- Level
	xp = "经验", -- XP
	energy = "能量", -- Energy
	wage = "工资", -- Wage
	age = "年龄", -- Age
	earnings = "收入", -- Earnings
	profit = "利润", -- Profit

	cto_missing_admin = "你需要是管理员才能执行此操作！", -- You need to be admin to do this!
	cto_missing_donator = "你需要是VIP才能执行此操作！", -- You need to be VIP to do this!

	key_place_desk = "左键：放置桌子", -- LMB: Place desk
	key_cancel_desk = "右键：取消", -- RMB: Cancel

	-- Permissions
	not_yours = "这不是你的桌面构建器！", -- This is not your deskbuilder!
	not_your_desk = "这张桌子不属于你！", -- This does not belong to you!

	-- Corporation
	corp_exists = "你已经拥有一家公司了。难道你想抛弃它吗？", -- You already have a corporation. Don't you want to take care of it?
	create_corp = "创建公司", -- Create Corporation
	create_corp_button = "创建公司（%price）", -- Create Corporation (%price)
	corp_name = "公司名称", -- Company name
	old_corp = "这是你之前的公司拥有的！", -- This belongs to your old Corporation!
	placeholder_name = "我的公司", -- My Company

	corp_created = "你成功创建了公司『%name』", -- You successfully created your company '%name'
	no_money_to_create_corp = "你没有 %money 来创建公司！", -- You don't have %money to create a company!
	corp_insufficient_level = "你的公司尚未达到等级 %level！", -- Your corporation has not yet passed level %level!
	corpname_too_long = "公司名称不能超过30个字符！", -- Your corporation name must not exceed the limit of 30 characters!
	corpname_empty = "公司名称不能为空！", -- Your corporation name cant be empty!
	corpname_too_short = "公司名称至少需要5个字符！", -- Your corporation name must be at least 5 characters long!
	corpname_default = "请为你的公司使用不同的名称！", -- Please use a different name for your corporation!

	corp_reached_level = "%name 达到了等级 %level", -- %name reached level %level

	-- Desks related
	desk_limit = "你已经达到了此类桌子的上限！", -- You have reached the limit of this desk!
	desk_no_money = "你的公司没有足够资金购买此桌子！", -- Your corporation does not have enough money to buy this desk!
	deskbuilder_limit = "你已经达到了桌面构建器上限！", -- You have reached the limit of deskbuilders!
	dismantle = "拆除桌子", -- Dismantle desk
	dismantle_vault = "拆除金库", -- Dismantle vault
	cant_sell = "你不能出售这张桌子！", -- You can't sell this desk!
	desk_sold = "你以 %price 售出了 %name", -- You sold %name for %price
	sell_desk = "出售桌子", -- Sell desk
	build_desk = "建造桌子", -- Build desk

	-- Coffee
	coffee_limit = "你已经达到了咖啡上限！", -- You have reached the limit of coffee!
	coffee_no_money = "你的公司没有足够资金购买此咖啡！", -- Your corporation does not have enough money to buy this coffee!

	coffee_black = "黑咖啡", -- Black coffee
	coffee_black_sugar = "黑咖啡加糖", -- Black coffee with sugar
	coffee_bean = "黑豆咖啡", -- Black bean coffee
	coffee_bean_sugar = "黑豆咖啡加糖", -- Black bean coffee with sugar

	-- Money deposit/withdraw
	withdraw_money = "取出资金", -- Withdraw money
	money_amount = "金额", -- Amount of money
	deposit_money = "存入资金", -- Deposit money
	withdrew_money = "你取出了 %amount", -- You withdrew %amount
	deposited_money = "你存入了 %amount", -- You deposited %amount
	vault_expanded = "你将金库扩容至 %amount，费用为 %price", -- You expanded your vault to hold %amount for %price
	no_money = "你在公司金库中没有足够的资金！", -- You dont have enough money in your company vault!
	no_money_user = "你没有足够的资金！", -- You dont have enough money!
	money_too_low = "选择的金额不能小于或等于零！", -- Your selected amount must not be equal to or below 0!

	-- Vault
	open_vault = "打开金库", -- Open vault
	close_vault = "关闭金库", -- Close vault
	sell_vault = "出售金库", -- Sell vault
	build_vault = "建造金库", -- Build vault
	upgrade_vault = "升级金库", -- Upgrade vault

	-- Workers
	select_worker = "选择员工", -- Select worker
	hire_worker = "雇佣 %s", -- Hire %s
	worker_hired = "你已雇佣 %name 成为新员工！", -- You hired %name as a new worker!
	worker_wage_unpayable = "你的公司资金不足，无法支付 %name 的工资", -- Your company does not have enough money to pay %name
	too_tired = "%name 太累了，无法工作！", -- %name is too tired to work!
	select_worker_first = "你必须先选择一名员工！", -- You must select a worker first!
	fire_worker = "解雇员工", -- Fire worker
	worker_fired = "你解雇了 %name", -- You fired %name
	asleep = "正在睡觉 - 按下 [%key] 唤醒", -- Asleep - [%key] to wake up
	new_workers_in = "新员工已入职", -- New workers in

	-- Destruction
	corp_rebellion = "员工发动了叛乱，烧毁了一切！", -- Your employees started a rebellion and burnt everything down!
	corp_bankrupt = "你的员工辞职了，因为你无法支付他们工资！", -- Your employees quit because you can't pay them!
	corp_lost = "你的公司主桌已被摧毁，公司倒闭了 :(", -- Your corporate desk got destroyed. Your Company is lost :(

	-- Desk names
	corporate_desk = "公司主桌", -- Corporate Desk
	basic_worker_desk = "初级员工桌", -- Basic Worker Desk
	intermediate_worker_desk = "中级员工桌", -- Intermediate Worker Desk
	advanced_worker_desk = "高级员工桌", -- Advanced Worker Desk
	ultimate_worker_desk = "终极员工桌", -- Ultimate Worker Desk
	secretary_desk = "秘书桌", -- Secretary Desk
	research_desk = "研究桌", -- Research Desk
	vault = "公司金库", -- Corporate vault

	-- Researches
	research_waiting = "等待中", -- Waiting
	research_description = "这里将显示研究描述", -- Here will be a description of the research
	wakeup_employees = "唤醒员工", -- Wakeup employees
	start_research = "开始研究", -- Start research
	select_research_first = "你必须先选择一个研究项目！", -- You must select a research option first!
	research_open = "打开研究项目以查看描述！", -- Open a research option to see it's description!
	research_finished = "你完成了 %name 的研究", -- You finished researching %name

	research_in_progress = "已经有一个研究在进行中！", -- There is already a research in progress!
	research_no_money = "你没有足够的资金开始该研究！", -- You don't have enough money to start this research!
	research_needed = "你需要先研究 %name！", -- You need to research %name first!
	research_started = "你开始研究 %name", -- You started researching %name

	research_efficiency = "快速研究者", -- Fast Researcher
	research_price_drop = "谈判专家", -- Negotiator
	xp_worker_1 = "机智员工 I", -- Smart worker I
	xp_worker_2 = "机智员工 II", -- Smart worker II
	xp_corp_1 = "机智公司 I", -- Smart Company I
	xp_corp_2 = "机智公司 II", -- Smart Company II
	research_wage_1 = "廉价劳动力 I", -- Cheap workers I
	research_wage_2 = "廉价劳动力 II", -- Cheap workers II
	research_wage_3 = "廉价劳动力 III", -- Cheap workers III
	automatic_coffee_self = "自助咖啡机", -- Selfserving Servant
	automatic_coffee = "咖啡服务员", -- Servant
	wakeup_employees = "叫醒员工！", -- Wake up!

	research_efficiency_desc = "所有研究速度提升10%", -- All researches will be 10% quicker
	research_price_drop_desc = "所有研究费用降低10%", -- All researches will cost 10% less
	xp_worker_1_desc = "员工获得经验提升10%", -- Your workers will gain 10% more XP.
	xp_worker_2_desc = "员工获得经验再次提升10%", -- Your workers will gain 10% more XP.
	xp_corp_1_desc = "公司获得经验提升25%", -- Your company will gain 25% more XP.
	xp_corp_2_desc = "公司获得经验提升10%", -- Your company will gain 10% more XP.
	research_wage_1_desc = "员工工资减少10%", -- The wage of your workers will be dropped by 10%.
	research_wage_2_desc = "员工工资额外减少10%", -- The wage of your workers will be dropped by an additional 10%.
	research_wage_3_desc = "员工工资再额外减少10%", -- The wage of your workers will be dropped by an additional 10%.

	wakeup_employees_desc = "秘书桌将在员工精力足够时自动唤醒他们", -- Your secretary desk will be able to wake up all sleeping workers as soon as their energy level is sufficient.
	automatic_coffee_desc = "秘书桌将能为所有员工（除自身）补充精力", -- Your secretary desk will be able to replenish the energy of all workers (except itself).
	automatic_coffee_self_desc = "秘书桌将能为自己补充精力", -- Your secretary desk will be able to replenish the energy of itself.
}

Corporate_Takeover:RegisterLang(lang.name, lang.short, lang.lang)