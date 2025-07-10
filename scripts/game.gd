extends Node


signal change_scene_request(scene: GameRoot.Scene)
signal sound_fx_request(sound: AudioLibrary.SoundFxs, volumn_db: float)

var rng: = RandomNumberGenerator.new()
var money: int = 0
var highscore: int = 0
var base_level_reward: int = 30
var tokens: int = 0

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
	BronzeBallsGetPegBonus,
	SilverBallsGetPegBonus,
	GoldBallsGetPegBonus,
	DiamondBallsGetPegBonus,
	PlatBallsGetPegBonus,
	MaxTokens,
	LessNegativePrizes,
	LessNegativePegs,
	
	# Prestige Upgrades
	DoubleMoneyEarned,
	TripleMoneyEarned,
	QuadurpleMoneyEarned,
	MagicBallsOnPegHit,
	PegsHaveChanceToSpawnMiniBalls,
	AutoDropper,
	AutoDropperRate,
	CannonMovesHorizontally,
	ExtraCannon,
	KeepMoneyOnPresstige,
	KeepUpgradesOnPrestige,
	BaseLevelRewardsUpX,
	PrizesAlwaysRespawn,
	PegsAlwaysRespawn,
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
const UPGRADE_PRESTIGE_TYPE: String = "upgrade_prestige_type"
enum UpgradeType { Gameplay, MoneyPerSecond }
enum UpgradePrestigeType { Normal, Prestige }




func add_money(amount: int):
	var new_amount = amount
	if amount > 0:
		if has_upgrade(Upgrades.QuadurpleMoneyEarned):
			new_amount = amount * 4
		elif has_upgrade(Upgrades.TripleMoneyEarned):
			new_amount = amount * 3
		elif has_upgrade(Upgrades.DoubleMoneyEarned):
			new_amount = amount * 2
	
	Game.money+=new_amount
	
	if new_amount > highscore:
		highscore = new_amount

	Game.money = max(0, Game.money)


func reset_all_upgrades():
	for upgrade in Upgrades.values():
		var data: Dictionary = upgrade_data.get(upgrade)
		if data.get_or_add(UPGRADE_PRESTIGE_TYPE, UpgradePrestigeType.Normal) == UpgradePrestigeType.Normal:
			upgrade_data.set(upgrade, upgrades_data_clone.get(upgrade))
	
var upgrade_data: Dictionary[Upgrades, Dictionary] = {
	Upgrades.PegsAlwaysRespawn: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Pegs will respawn after being claimed",
		DESCRIPTION: "Peg respawns after claim",
		INITIAL_VALUE: 1.0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 1, # 1 token
		CURRENT_PRICE: 1,
	},
	Upgrades.PrizesAlwaysRespawn: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Prize will respawn after being claimed",
		DESCRIPTION: "Prize respawns after claim",
		INITIAL_VALUE: 1.0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 1, # 1 token
		CURRENT_PRICE: 1,
	},
	
	
	# Prestige Upgrades (Token-based pricing)
	Upgrades.DoubleMoneyEarned: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Double Money Earned",
		DESCRIPTION: "2x all money earned from prizes",
		INITIAL_VALUE: 1.0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 1, # 1 token
		CURRENT_PRICE: 1,
	},
	Upgrades.TripleMoneyEarned: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Triple Money Earned",
		DESCRIPTION: "3x all money earned from prizes",
		INITIAL_VALUE: 2.0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 3, # 3 tokens
		CURRENT_PRICE: 3,
	},
	Upgrades.QuadurpleMoneyEarned: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Quadruple Money Earned",
		DESCRIPTION: "4x all money earned from prizes",
		INITIAL_VALUE: 3.0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 6, # 6 tokens
		CURRENT_PRICE: 6,
	},
	Upgrades.MagicBallsOnPegHit: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Magic Balls on Peg Hit",
		DESCRIPTION: "+1% Chance ball turns into magic ball when hitting pegs",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.01,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 1, # 2 tokens
		CURRENT_PRICE: 1,
	},
	Upgrades.PegsHaveChanceToSpawnMiniBalls: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Pegs Spawn Mini Balls",
		DESCRIPTION: "+2% Chance pegs spawn mini balls",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.02,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 2, # 2 tokens
		CURRENT_PRICE: 2,
	},
	Upgrades.AutoDropper: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Auto Dropper",
		DESCRIPTION: "Automatically drops balls every 5 seconds",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL:1,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 4, # 4 tokens
		CURRENT_PRICE: 4,
	},
	Upgrades.AutoDropperRate: {
		NAME: "Auto Dropper Rate",
		DESCRIPTION: "-0.5 seconds from auto dropper rate",
		INITIAL_VALUE: 5,
		VALUE_PER_LEVEL: -0.50,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 9,
		INITIAL_PRICE: 100, # 1 token
		CURRENT_PRICE: 100,
	},
	Upgrades.CannonMovesHorizontally: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Cannon Moves Horizontally",
		DESCRIPTION: "Cannon can move left and right",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 5, # 5 tokens
		CURRENT_PRICE: 5,
	},
	Upgrades.ExtraCannon: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Extra Cannon",
		DESCRIPTION: "+1 additional cannon",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 2,
		INITIAL_PRICE: 8, # 8 tokens
		CURRENT_PRICE: 8,
	},
	Upgrades.KeepMoneyOnPresstige: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Keep Money on Prestige",
		DESCRIPTION: "Keep +10% of money when prestiging",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 10, # 10 tokens
		CURRENT_PRICE: 10,
	},
	Upgrades.KeepUpgradesOnPrestige: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Keep Upgrades on Prestige",
		DESCRIPTION: "Keep upgrades when prestiging",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.2,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 12, # 12 tokens
		CURRENT_PRICE: 12,
	},
	Upgrades.BaseLevelRewardsUpX: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Base Level Rewards Up",
		DESCRIPTION: "+x2 base reward values",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 2,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 3, # 3 tokens
		CURRENT_PRICE: 3,
	},
	
	# Regular Upgrades (Much higher prices)
	Upgrades.LessNegativePegs: {
		NAME: "Less Negative Pegs",
		DESCRIPTION: "-1% Chance for Negative pegs to spawn",
		INITIAL_VALUE: 0.05,
		VALUE_PER_LEVEL: -0.01,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 200, # Increased from 20
	},
	Upgrades.LessNegativePrizes: {
		NAME: "Less Negative Prizes",
		DESCRIPTION: "-2% Chance for Negative prizes to spawn",
		INITIAL_VALUE: 0.10,
		VALUE_PER_LEVEL: -0.025,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 500, # Increased from 30
	},
	Upgrades.NewMachines: {
		NAME: "New Machines",
		DESCRIPTION: "+[$96 / secs]", # Halved from 160
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 96,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 5000, # Increased from 960
		CURRENT_PRICE: 5000,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.ShinyBalls: {
		NAME: "Shiny Balls",
		DESCRIPTION: "+[$48 / secs]", # Halved from 80
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 48,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 2500, # Increased from 480
		CURRENT_PRICE: 2500,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.VipLounge: {
		NAME: "VIP Lounge",
		DESCRIPTION: "+[$24 / secs]", # Halved from 40
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 24,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 1200, # Increased from 240
		CURRENT_PRICE: 1200,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.ComfySeats: {
		NAME: "More Comfortable Seats",
		DESCRIPTION: "+[$12 / secs]", # Halved from 20
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 12,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 600, # Increased from 120
		CURRENT_PRICE: 600,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.DecorUpgrade: {
		NAME: "Decor Upgrade",
		DESCRIPTION: "+[$6 / secs]", # Halved from 10
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 6,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 300, # Increased from 60
		CURRENT_PRICE: 300,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.FreeSnacks: {
		NAME: "Free Snacks",
		DESCRIPTION: "+[$3 / secs]", # Halved from 5
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 3,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 150, # Increased from 30
		CURRENT_PRICE: 150,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.ChanceBallRespawnsOnMissedPrize: {
		NAME: "Balls respawn on miss",
		DESCRIPTION: "+5% Chance that Ball will respawn on missed Prize", # Halved from 10%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.05,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 100, # Increased from 10
		CURRENT_PRICE: 100,
	},
	Upgrades.BronzeBallsSpawnPercentage: {	
		NAME: "Bronze Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Bronze Balls will spawn, bronze balls give +5x prize", # Reduced from 2.5%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20, # Increased max level
		INITIAL_PRICE: 800, # Increased from 100
		CURRENT_PRICE: 800,
	},
	Upgrades.BronzeBallsGetPegBonus: {	
		NAME: "Bronze Balls effect peg bonus",
		DESCRIPTION: "Bronze balls give +5x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 2000, # Increased from 500
	},
	Upgrades.SilverBallsSpawnPercentage: {
		NAME: "Silver Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Silver Balls will spawn, silver balls give +10x prize", # Reduced from 2.5%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20,
		INITIAL_PRICE: 4000, # Increased from 1000
		CURRENT_PRICE: 4000,
	},
	Upgrades.SilverBallsGetPegBonus: {	
		NAME: "Silver Balls effect peg bonus",
		DESCRIPTION: "Silver balls give +10x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0, # Fixed from 0.025
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 8000, # Increased from 1000
	},
	Upgrades.GoldBallsSpawnPercentage: {
		NAME: "Gold Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Gold Balls will spawn, gold balls give +25x prize", # Reduced from 2.5%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20,
		INITIAL_PRICE: 15000, # Increased from 2000
		CURRENT_PRICE: 15000,
	},
	Upgrades.GoldBallsGetPegBonus: {	
		NAME: "Gold Balls effect peg bonus",
		DESCRIPTION: "Gold balls give +25x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0, # Fixed from 0.025
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 30000, # Increased from 4000
	},
	Upgrades.DiamonBallsSpawnPercentage: {
		NAME: "Diamond Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Diamond Balls will spawn, diamond balls give +50x prize", # Fixed description
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20,
		INITIAL_PRICE: 50000, # Increased from 4000
		CURRENT_PRICE: 50000,
	},
	Upgrades.DiamondBallsGetPegBonus: {	
		NAME: "Diamond Balls effect peg bonus",
		DESCRIPTION: "Diamond balls give +50x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0, # Fixed from 0.025
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 100000, # Increased from 8000
	},
	Upgrades.PlatinumBallsSpawnPercentage: {
		NAME: "Platinum Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Platinum Balls will spawn, platinum balls give +100x prize", # Reduced from 2.5%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20,
		INITIAL_PRICE: 200000, # Increased from 8000
		CURRENT_PRICE: 200000,
	},
	Upgrades.PlatBallsGetPegBonus: {	
		NAME: "Platinum Balls effect peg bonus",
		DESCRIPTION: "Platinum balls give +100x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0, # Fixed from 0.025
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 400000, # Increased from 16000
	},
	Upgrades.TokensCanSpawnPercentage: {
		NAME: "Prestige Tokens have chance to spawn",
		DESCRIPTION: "+2% Chance that Prestige Tokens will spawn as prizes", # Reduced from 5%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.02,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5, # Increased max level
		INITIAL_PRICE: 75000, # Increased from 10000
		CURRENT_PRICE: 75000,
	},
	Upgrades.MaxTokens: {
		NAME: "Prestige Tokens max +1",
		DESCRIPTION: "+1 Capacity to prestige tokens",
		INITIAL_VALUE: 3,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 7, # Increased max level
		INITIAL_PRICE: 500000, # Increased from 100000
		CURRENT_PRICE: 500000,
	},
	Upgrades.ChanceToSplitBallOnPegHit: {
		NAME: "Chance to Split Ball on Peg Hit",
		DESCRIPTION: "+0.15% Chance that ball will split on peg hit", # Reduced from 0.25%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.0015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15, # Increased max level
		INITIAL_PRICE: 300, # Increased from 50
		CURRENT_PRICE: 300,
	},
	Upgrades.ChanceToSpawnBallOnPrizeClaim: {
		NAME: "Chance to Respawn Ball",
		DESCRIPTION: "+3% Chance that ball will respawn", # Reduced from 5%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.03,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 8, # Increased max level
		INITIAL_PRICE: 250, # Increased from 30
		CURRENT_PRICE: 250,
	},
	Upgrades.MaxRewardAmountPercentage: {
		NAME: "Max Reward +Percentage",
		DESCRIPTION: "+25% Max reward value for each level", # Reduced from 50%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.25,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15, # Increased max level
		INITIAL_PRICE: 400, # Increased from 60
		CURRENT_PRICE: 400,
	},
	Upgrades.MaxBalls: {
		NAME: "Max Balls",
		DESCRIPTION: "Max balls per game",
		INITIAL_VALUE: 3,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 25,
		INITIAL_PRICE: 25, # Increased from 5
		CURRENT_PRICE: 25,
	},
	Upgrades.MinRewardColumns: {
		NAME: "Min Rewards Columns",
		DESCRIPTION: "Min amount of reward columns in game",
		INITIAL_VALUE: 2,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 6,
		INITIAL_PRICE: 150, # Increased from 20
		CURRENT_PRICE: 150,
	},
	Upgrades.Customers: {
		NAME: "Customers",
		DESCRIPTION: "+[$1 / secs]", # Reduced from 2.5
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15, # Increased max level
		INITIAL_PRICE: 20, # Increased from 15
		CURRENT_PRICE: 20,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.PegsCanHavePrizesSpawnPercetange: {
		NAME: "Pegs Can Have Prizes",
		DESCRIPTION: "+1.5% Chance pegs have prizes", # Reduced from 2.5%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 50, # Increased max level
		INITIAL_PRICE: 200, # Increased from 40
		CURRENT_PRICE: 200,
	},
	Upgrades.PegsPrizeAmount: {
		NAME: "Max Peg prize amount",
		DESCRIPTION: "+3% max prize amount for pegs", # Reduced from 5%
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.03,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15, # Increased max level
		INITIAL_PRICE: 350, # Increased from 50
		CURRENT_PRICE: 350,
	},
	Upgrades.PrizesCanBeClaimedXTimes: {
		NAME: "Prizes can be claimed multiple times",
		DESCRIPTION: "+1 a prize can be claimed",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15, # Increased max level
		INITIAL_PRICE: 800, # Increased from 100
		CURRENT_PRICE: 800,
	},
	Upgrades.PrizesCanBeClaimedXTimesPerPeg: {
		NAME: "Peg Prizes can be claimed multiple times",
		DESCRIPTION: "+1 a peg prize can be claimed",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10, # Increased max level
		INITIAL_PRICE: 1000, # Increased from 100
		CURRENT_PRICE: 1000,
	},
}


func debug_values():
	money = 1000000
	tokens = 1000


var upgrades_data_clone: Dictionary
func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	upgrades_data_clone = upgrade_data.duplicate(true)
	#if EngineDebugger.is_active():
		#debug_values()

func is_upgrade_money_per_second(upgrade: Upgrades) -> bool:
	return upgrade_data.get(upgrade).get_or_add(UPGRADE_TYPE, UpgradeType.Gameplay) == UpgradeType.MoneyPerSecond

func calculate_per_second_money() -> int:
	var sum = 0
	for upgrade in upgrade_data.keys():
		var upgrade_level: int = upgrade_data.get(upgrade).get(CURRENT_LEVEL)
		if upgrade_level > 0 && upgrade_data.get(upgrade).get_or_add(UPGRADE_TYPE, UpgradeType.Gameplay) == UpgradeType.MoneyPerSecond:
			sum+= get_upgrade_current_value(upgrade)
	return sum

func get_upgrade_next_cost(upgrade: Upgrades) -> int:
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
	if is_upgrade_prestige_upgrade(upgrade):
		tokens-= get_upgrade_next_cost(upgrade)
	else:
		money-= get_upgrade_next_cost(upgrade)
		
	upgrade_data.get(upgrade).set(CURRENT_LEVEL, upgrade_data.get(upgrade).get_or_add(CURRENT_LEVEL, 0) + 1)
	
func get_upgrade_name(upgrade: Upgrades) -> String:
	var _name: String = upgrade_data.get(upgrade).get_or_add(NAME, "")
	return _name
	
	
func is_upgrade_prestige_upgrade(upgrade: Upgrades) -> bool:
	return upgrade_data.get(upgrade).get_or_add(UPGRADE_PRESTIGE_TYPE, UpgradePrestigeType.Normal) == UpgradePrestigeType.Prestige
	
	
func get_upgrade_description(upgrade: Upgrades) -> String:
	var description: String = upgrade_data.get(upgrade).get_or_add(DESCRIPTION, "")
	return description

func get_upgrade_max_level(upgrade: Upgrades) -> int:
	var upgrade_level: int = upgrade_data.get(upgrade).get_or_add(MAX_LEVEL, 1)
	return upgrade_level

func request_sfx(sfx: AudioLibrary.SoundFxs, volumn_db: float = 0.0) -> void:
	sound_fx_request.emit(sfx, volumn_db)


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
	
	
func should_negative_upgrade_be_triggered_chance(upgrade: Upgrades) -> bool:
	var actual_spawn_percentage: float = Game.get_upgrade_current_value(upgrade)
	return rng.randf_range(0, 1) < actual_spawn_percentage

func change_to_upgrades_scene():
	save_game()
	change_scene_request.emit(GameRoot.Scene.Upgrades)
	

func change_to_pachinko_scene():
	save_game()
	change_scene_request.emit(GameRoot.Scene.GameBoard)

func change_to_prestige_scene():
	if !has_upgrade(Game.Upgrades.KeepUpgradesOnPrestige):
		Game.reset_all_upgrades()
	if has_upgrade(Game.Upgrades.KeepMoneyOnPresstige):
		Game.money = Game.money * get_upgrade_current_value(Game.Upgrades.KeepMoneyOnPresstige)
	else:
		Game.money = 0
	change_scene_request.emit(GameRoot.Scene.Prestige)


func get_current_level_base_reward() -> int:
	if has_upgrade(Game.Upgrades.BaseLevelRewardsUpX):
		return base_level_reward * get_upgrade_current_value(Game.Upgrades.BaseLevelRewardsUpX)
	return base_level_reward

func format_scientific(num: int) -> String:
	var exponent = 0
	var value = float(num)
	
	while value >= 10.0:
		value /= 10.0
		exponent += 1
	
	# Format with 2 decimal places for the coefficient, using floor to round down
	if value == int(value):
		return "%de%d" % [int(value), exponent]
	else:
		var floored_value = floor(value * 100.0) / 100.0  # Floor to 2 decimal places
		return "%.2fe%d" % [floored_value, exponent]

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
			# Floor to 1 decimal place to round down
			var floored_value = floor(value * 10.0) / 10.0
			return "%.1f%s" % [floored_value, suffixes[magnitude]]

var path: String = "user://savegame.save"

func has_save() -> bool:
	return FileAccess.file_exists(path)
	
	
func save_game():
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	
	if save_file == null:
		printerr("Error opening save file for writing")
		return
		
	var dict: Dictionary = {
		"upgrades": upgrade_data,
		"money": money,
		"tokens": tokens,
		"settings": {
			"sfx": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Sfx")),
			"music": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music")),
			"master": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master")),
		}
	}
	var json_string = JSON.stringify(dict)
	save_file.store_string(json_string)
	save_file.close()
	print("Game saved successfully!")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if save_loaded:
			save_game()
		get_tree().quit() # default behavior


var save_loaded: = false


func load_save():
	
	if not FileAccess.file_exists(path):
		print("Save file doesn't exist")
		return
	
	
	var save_file = FileAccess.open(path, FileAccess.READ)
	if save_file == null:
		print("Error opening save file for reading")
		return
	
	var json_string = save_file.get_as_text()
	save_file.close()
	save_loaded = true
	# Parse JSON back to dictionary
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	var node_data: Dictionary = json.data
	var raw_upgrades: Dictionary = node_data["upgrades"]
	for key in raw_upgrades:
		var int_key = int(key)  # JSON keys are strings, convert to int first
		var upgrade_enum = int_key as Upgrades  # Convert int to enum
		upgrade_data[upgrade_enum] = raw_upgrades[key] as Dictionary
	
	money = node_data["money"]
	tokens = node_data["tokens"]
	upgrades_data_clone = upgrade_data.duplicate(true)
	
	if node_data.has("settings"):
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sfx"), node_data.get("settings").get("sfx"))
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), node_data.get("settings").get("music"))
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), node_data.get("settings").get("master"))
	print("Game loaded successfully!")
