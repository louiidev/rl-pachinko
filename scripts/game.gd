extends Node

var pachinko_scene: PackedScene = preload("res://scenes/Main.tscn")
var upgrades_scene: PackedScene = preload("res://scenes/Upgrades.tscn")

var rng: = RandomNumberGenerator.new()
var money = 300000
var money_this_game = 0
enum Upgrades {
	MaxRewardAmountPercentage,
	MinRewardColumns, 
	MaxBalls, 
	ShowPrizes,
	Customers, 
	PegsCanHavePrizesSpawnPercetange, 
	PegsPrizeAmount, 
	PrizesCanBeClaimedXTimes, 
	PrizesCanBeClaimedXTimesPerPeg,
	ChanceToSpawnBallOnPrizeClaim,
	ChanceToSplitBallOnPegHit,
}

const NAME: String = "name"
const CURRENT_PRICE: String = "current_price"
const DESCRIPTION: String = "description"
const INITIAL_VALUE: String = "initial_value"
const CURRENT_LEVEL: String = "current_level"
const MAX_LEVEL: String = "max_level"
const INITIAL_PRICE: String = "initial_price"
const VALUE_PER_LEVEL: String = "value_per_level"
const UPGRADE_TYPE: String = "upgrade_type"
enum UpgradeType { Gameplay, MoneyPerSecond }

var upgrade_data: Dictionary[Upgrades, Dictionary] = {
	Upgrades.ChanceToSplitBallOnPegHit: {
		NAME: "Chance to Split Ball on Peg Hit",
		DESCRIPTION: "+1% Chance that ball will split on peg hit",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.01,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.ChanceToSpawnBallOnPrizeClaim: {
		NAME: "Chance to Respawn Ball",
		DESCRIPTION: "+5% Chance that ball will respawn",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.05,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.MaxRewardAmountPercentage: {
		NAME: "Max Reward +Percetange",
		DESCRIPTION: "+10% Max reward value for each level",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.MaxBalls: {
		NAME: "Max Balls ",
		DESCRIPTION: "Max balls per game",
		INITIAL_VALUE: 3,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 50,
		CURRENT_PRICE: 50,
	},
	Upgrades.ShowPrizes: {
		NAME: "Show Prize Amount",
		DESCRIPTION: "Shows the prize amount",
		INITIAL_VALUE: true,
		CURRENT_LEVEL: 1,
		VALUE_PER_LEVEL: true,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.MinRewardColumns: {
		NAME: "Min Rewards Columns",
		DESCRIPTION: "Min amount of reward columns in game",
		INITIAL_VALUE: 2,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.Customers: {
		NAME: "Customers",
		DESCRIPTION: "+[$10 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 5,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 30,
		CURRENT_PRICE: 30,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.PegsCanHavePrizesSpawnPercetange: {
		NAME: "Pegs Can Have Prizes",
		DESCRIPTION: "+2.5% Chance pegs have prizes",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.025,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.PegsPrizeAmount: {
		NAME: "Max Peg prize amount",
		DESCRIPTION: "+5% max prize amount for pegs",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.05,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.PrizesCanBeClaimedXTimes: {
		NAME: "Prizes can be claimed multiple times",
		DESCRIPTION: "+1 a prize can be claimed",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.PrizesCanBeClaimedXTimesPerPeg: {
		NAME: "Peg Prizes can be claimed multiple times",
		DESCRIPTION: "+1 a peg prize can be claimed",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
}


func calculate_per_second_money() -> int:
	var sum = 0
	for upgrade in upgrade_data.keys():
		var upgrade_level: int = upgrade_data[upgrade].get(CURRENT_LEVEL)
		if upgrade_level > 0 && upgrade_data[upgrade].get_or_add(UPGRADE_TYPE, UpgradeType.Gameplay) == UpgradeType.MoneyPerSecond:
			sum+= get_upgrade_current_value(upgrade)
	return sum

func get_upgrade_current_cost(upgrade: Upgrades) -> int:
	var level :int= upgrade_data[upgrade].get(CURRENT_LEVEL)
	var initial_price: int= upgrade_data[upgrade].get(INITIAL_PRICE)
	return initial_price + (level * initial_price)
	
func get_upgrade_current_value(upgrade: Upgrades) -> float:
	var upgrade_level: int = get_upgrade_current_level(upgrade)
	var value_per_level: float = upgrade_data[upgrade].get_or_add(VALUE_PER_LEVEL, 0)
	var initial_value: float = upgrade_data[upgrade].get_or_add(INITIAL_VALUE, 0)
	return initial_value + value_per_level * upgrade_level
	
func get_upgrade_current_level(upgrade: Upgrades) -> int:
	var upgrade_level: int = upgrade_data[upgrade].get_or_add(CURRENT_LEVEL, 0)
	return upgrade_level

func on_upgrade_level_up(upgrade: Upgrades):
	if get_upgrade_current_level(upgrade) >= get_upgrade_max_level(upgrade):
		return
	money-= upgrade_data[upgrade].get(CURRENT_PRICE)
	upgrade_data[upgrade].set(CURRENT_LEVEL, upgrade_data[upgrade].get_or_add(CURRENT_LEVEL, 0) + 1)
	upgrade_data[upgrade].set(
		CURRENT_PRICE, 
		upgrade_data[upgrade].get(CURRENT_PRICE) + upgrade_data[upgrade].get(INITIAL_PRICE)
	)
	
func get_upgrade_name(upgrade: Upgrades) -> String:
	var name: String = upgrade_data[upgrade].get_or_add(NAME, "")
	return name
	
func get_upgrade_description(upgrade: Upgrades) -> String:
	var description: String = upgrade_data[upgrade].get_or_add(DESCRIPTION, "")
	return description

func get_upgrade_max_level(upgrade: Upgrades) -> int:
	var upgrade_level: int = upgrade_data[upgrade].get_or_add(MAX_LEVEL, 1)
	return upgrade_level
	


func has_upgrade(upgrade: Upgrades) -> bool:
	return upgrade_data.get(upgrade).get_or_add(CURRENT_LEVEL, 0) > 0
	
var countdown = 1.0
func _process(delta: float) -> void:
	countdown-= delta
	if countdown <=0:
		countdown = 1.0
		money+= calculate_per_second_money()
	
	

func change_to_upgrades_scene():
	get_tree().change_scene_to_packed(upgrades_scene)

func change_to_pachinko_scene():
	get_tree().change_scene_to_packed(pachinko_scene)


func get_current_level_base_reward() -> int:
	return 5


func format_scientific(num: int) -> String:
	var exponent = 0
	var value = float(num)
	
	while value >= 10.0:
		value /= 10.0
		exponent += 1
	
	# Format with 2 decimal places for the coefficient
	if value == int(value):
		return "%de%d" % [int(value), exponent]
	else:
		return "%.2fe%d" % [value, exponent]

func format_number_precise(num: int, sci_threshold: int = 1000000000000000) -> String:
	var suffixes = ["", "K", "M", "B", "T"]
	var magnitude = 0
	var value = float(num)
	
	# Check if we should use scientific notation
	if num >= sci_threshold:
		return format_scientific(num)
	
	while value >= 1000.0 and magnitude < suffixes.size() - 1:
		value /= 1000.0
		magnitude += 1
	
	if magnitude == 0:
		return str(int(value))
	else:
		# Remove decimal if it's a whole number
		if value == int(value):
			return str(int(value)) + suffixes[magnitude]
		else:
			return "%.1f%s" % [value, suffixes[magnitude]]
