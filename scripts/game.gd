extends Node


signal change_scene_request(scene: GameRoot.Scene)

var rng: = RandomNumberGenerator.new()
var money = 300000
var money_this_game = 0
enum Upgrades {
	MaxRewardAmountPercentage,
	MinRewardColumns, 
	MaxBalls, 
	Customers,
	PegsCanHavePrizesSpawnPercetange, 
	PegsPrizeAmount, 
	PrizesCanBeClaimedXTimes, 
	PrizesCanBeClaimedXTimesPerPeg,
	ChanceBallRespawnsOnMissedPrize,
	ChanceToSpawnBallOnPrizeClaim,
	ChanceToSplitBallOnPegHit,
	BronzeBallsSpawnPercentage,
	SilverBallsSpawnPercentage,
	GoldBallsSpawnPercentage,
	DiamonBallsSpawnPercentage,
	PlatinumBallsSpawnPercentage,
	TokensCanSpawnPercentage,
	FreeSnacks,
	DecorUpgrade,
	ComfySeats,
	VipLounge,
	ShinyBalls,
	NewMachines,
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
	Upgrades.NewMachines: {
		NAME: "New Machines",
		DESCRIPTION: "+[$320 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 320,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 960,
		CURRENT_PRICE: 960,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.ShinyBalls: {
		NAME: "Shiny Balls",
		DESCRIPTION: "+[$160 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 160,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 480,
		CURRENT_PRICE: 480,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.VipLounge: {
		NAME: "VIP Lounge",
		DESCRIPTION: "+[$80 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 80,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 240,
		CURRENT_PRICE: 240,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.ComfySeats: {
		NAME: "More Comfortable Seats",
		DESCRIPTION: "+[$40 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 40,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 120,
		CURRENT_PRICE: 120,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.DecorUpgrade: {
		NAME: "Decor Upgrade",
		DESCRIPTION: "+[$20 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 20,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 60,
		CURRENT_PRICE: 60,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.FreeSnacks: {
		NAME: "Free Snacks",
		DESCRIPTION: "+[$10 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 10,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 30,
		CURRENT_PRICE: 30,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.ChanceBallRespawnsOnMissedPrize: {
		NAME: "Balls respawn on miss",
		DESCRIPTION: "+10% Chance that Ball will respawn on missed Prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 10,
		CURRENT_PRICE: 10,
	},
	Upgrades.BronzeBallsSpawnPercentage: {	
		NAME: "Bronze Balls have chance to spawn",
		DESCRIPTION: "+2.5% Chance that Bronze Balls will spawn, bronze balls give +5x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.025,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.SilverBallsSpawnPercentage: {
		NAME: "Silver Balls have chance to spawn",
		DESCRIPTION: "+2.5% Chance that Silver Balls will spawn, bronze balls give +10x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.025,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 1000,
		CURRENT_PRICE: 1000,
	},
	Upgrades.GoldBallsSpawnPercentage: {
		NAME: "Gold Balls have chance to spawn",
		DESCRIPTION: "+2.5% Chance that Gold Balls will spawn, bronze balls give +25x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.025,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 2000,
		CURRENT_PRICE: 2000,
	},
	Upgrades.DiamonBallsSpawnPercentage: {
		NAME: "Bronze Balls have chance to spawn",
		DESCRIPTION: "+2.5% Chance that Bronze Balls will spawn, bronze balls give +50x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.025,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 3000,
		CURRENT_PRICE: 3000,
	},
	Upgrades.PlatinumBallsSpawnPercentage: {
		NAME: "Platinum Balls have chance to spawn",
		DESCRIPTION: "+2.5% Chance that Platinum Balls will spawn, bronze balls give +100x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.025,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 4000,
		CURRENT_PRICE: 4000,
	},
	Upgrades.TokensCanSpawnPercentage: {
		NAME: "Prestige Tokens have chance to spawn",
		DESCRIPTION: "+3% Chance that Prestige Tokens will spawn as prizes",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.03,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 500,
		CURRENT_PRICE: 500,
	},
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
		DESCRIPTION: "+50% Max reward value for each level",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.5,
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
		MAX_LEVEL: 100,
		INITIAL_PRICE: 50,
		CURRENT_PRICE: 50,
	},
	Upgrades.MinRewardColumns: {
		NAME: "Min Rewards Columns",
		DESCRIPTION: "Min amount of reward columns in game",
		INITIAL_VALUE: 2,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 6,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.Customers: {
		NAME: "Customers",
		DESCRIPTION: "+[$5 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 5,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 15,
		CURRENT_PRICE: 15,
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
		var upgrade_level: int = upgrade_data.get(upgrade).get(CURRENT_LEVEL)
		if upgrade_level > 0 && upgrade_data.get(upgrade).get_or_add(UPGRADE_TYPE, UpgradeType.Gameplay) == UpgradeType.MoneyPerSecond:
			sum+= get_upgrade_current_value(upgrade)
	return sum

func get_upgrade_current_cost(upgrade: Upgrades) -> int:
	var level :int= upgrade_data.get(upgrade).get(CURRENT_LEVEL)
	var initial_price: int= upgrade_data.get(upgrade).get(INITIAL_PRICE)
	return initial_price + (level * initial_price)
	
func get_upgrade_current_value(upgrade: Upgrades) -> float:
	var upgrade_level: int = get_upgrade_current_level(upgrade)
	var value_per_level: float = upgrade_data.get(upgrade).get_or_add(VALUE_PER_LEVEL, 0)
	var initial_value: float = upgrade_data.get(upgrade).get_or_add(INITIAL_VALUE, 0)
	return initial_value + value_per_level * upgrade_level
	
func get_upgrade_current_level(upgrade: Upgrades) -> int:
	var upgrade_level: int = upgrade_data.get(upgrade).get_or_add(CURRENT_LEVEL, 0)
	return upgrade_level

func on_upgrade_level_up(upgrade: Upgrades):
	if get_upgrade_current_level(upgrade) >= get_upgrade_max_level(upgrade):
		return
	money-= upgrade_data.get(upgrade).get(CURRENT_PRICE)
	upgrade_data.get(upgrade).set(CURRENT_LEVEL, upgrade_data.get(upgrade).get_or_add(CURRENT_LEVEL, 0) + 1)
	upgrade_data.get(upgrade).set(
		CURRENT_PRICE, 
		upgrade_data.get(upgrade).get(CURRENT_PRICE) + upgrade_data.get(upgrade).get(INITIAL_PRICE)
	)
	
func get_upgrade_name(upgrade: Upgrades) -> String:
	var _name: String = upgrade_data.get(upgrade).get_or_add(NAME, "")
	return _name
	
func get_upgrade_description(upgrade: Upgrades) -> String:
	var description: String = upgrade_data.get(upgrade).get_or_add(DESCRIPTION, "")
	return description

func get_upgrade_max_level(upgrade: Upgrades) -> int:
	var upgrade_level: int = upgrade_data.get(upgrade).get_or_add(MAX_LEVEL, 1)
	return upgrade_level


func has_upgrade(upgrade: Upgrades) -> bool:
	return upgrade_data.get(upgrade).get_or_add(CURRENT_LEVEL, 0) > 0
	
var countdown = 1.0
func _process(delta: float) -> void:
	countdown-= delta
	if countdown <=0:
		countdown = 1.0
		money+= calculate_per_second_money()
	
#	If the upgrade shoudl be triggered
func should_upgrade_be_triggered_chance(upgrade: Upgrades) -> bool:
	if !has_upgrade(upgrade):
		return false
	var actual_spawn_percentage: float = Game.get_upgrade_current_value(upgrade)
	return rng.randf_range(0, 1) < actual_spawn_percentage

func change_to_upgrades_scene():
	change_scene_request.emit(GameRoot.Scene.Upgrades)
	

func change_to_pachinko_scene():
	change_scene_request.emit(GameRoot.Scene.GameBoard)

func get_current_level_base_reward() -> int:
	return 10

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
