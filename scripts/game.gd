extends Node


signal change_scene_request(scene: GameRoot.Scene)
signal sound_fx_request(sound: AudioLibrary.SoundFxs, volumn_db: float)

var rng: = RandomNumberGenerator.new()
var money: float = 0
var money_this_round: float = 0
var level: int = 1
var multiplier: float = 1.0
var base_level_reward_multiplier: float = 2
var tokens: int = 0
var game_dt: float = 0.0
var disabled_transition: bool = false

enum Upgrades {
	MaxRewardAmountPercentage,
	MinRewardColumns,
	MaxBallBounceV1,
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

	# Prestige Upgrades
	DoubleMoneyEarned,
	TripleMoneyEarned,
	QuadurpleMoneyEarned,
	MagicBallsOnPegHit,
	PegsHaveChanceToSpawnMiniBalls,
	ReduceShotDelayV1,
	ExtraCannon,
	KeepMoneyOnPresstige,
	BaseLevelRewardsUpX,

	# NEW UPGRADES
	AttackDmgUpV1,
	MaxLevelTimeV1,
	MaxLevelTimeV2,
	MaxLevelTimeV3,
	PegDestoryedAddsLevelTimeV1,
	PegDestoryedAddsLevelTimeV2,
	PickUpRadiusV1,
	BallsPickupRewardsV1,
	BallPickupRadiusV1,
	AttackDmgUpV2,
	CritChanceV1,
	CritChanceV2,
	ReduceShotDelayV2,
	ReduceShotDelayV3,
	MaxBallBounceV2,
	ReduceShotDelayV4,
	
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



var base_value: float = 25      # Starting base
var linear_factor: float = 15   # Linear scaling (keeps early levels smooth)
var exponent: float = 1.8       # Exponential growth (faster ramp-up)
var post_20_multiplier: float = 1.5  # Extra kick after level 20

func calculate_target() -> float:
	var next_target = base_value * level + linear_factor * pow(level, exponent)
	
	if Game.has_upgrade(Game.Upgrades.DoubleMoneyEarned):
		next_target*= 1.5
	if Game.has_upgrade(Game.Upgrades.TripleMoneyEarned):
		next_target*= 1.5
	if Game.has_upgrade(Game.Upgrades.QuadurpleMoneyEarned):
		next_target*= 1.5	
	
	# Extra difficulty spike after level 20
	if level > 20:
		next_target *= post_20_multiplier

	return next_target
	
var bonus_level_mod = 30
func calculate_bonus() -> float:
	var min_range:= 0.1
	var max_range:= 0.7
	if Game.has_upgrade(Game.Upgrades.DoubleMoneyEarned):
		min_range*= 1.5
		max_range*= 1.5
	if Game.has_upgrade(Game.Upgrades.TripleMoneyEarned):
		min_range*= 1.5
		
		max_range*= 1.5
	if Game.has_upgrade(Game.Upgrades.QuadurpleMoneyEarned):
		min_range*= 1.5
		
		max_range*= 1.5
	
	return level * bonus_level_mod * rng.randf_range(min_range, max_range)

func end_of_round(mult: float):
	Game.money+= Game.money_this_round * mult
	Game.money_this_round = 0
	

func add_money(amount: int):
	var new_amount = amount


	#Game.money+=new_amount
	Game.money_this_round+= new_amount



enum LevelBonus {Money, Token}
func get_level_bonus_type() -> LevelBonus:
	if level % 10 == 0:
		return LevelBonus.Token
	if level > 20 && level % 5 == 0:
		return LevelBonus.Token
	
	return LevelBonus.Money

func reset_all_upgrades():
	for upgrade: Upgrades in upgrade_data.keys():
		var data: Dictionary = upgrade_data.get(upgrade)
		if data.get_or_add(UPGRADE_PRESTIGE_TYPE, UpgradePrestigeType.Normal) == UpgradePrestigeType.Normal && upgrade != Upgrades.MaxTokens:
			upgrade_data.get(upgrade).set(CURRENT_LEVEL, 0)
		else:
			print("wont reset upgrade ", Upgrades.keys()[upgrade], " ", data.get(UPGRADE_PRESTIGE_TYPE))


var upgrade_data: Dictionary[Upgrades, Dictionary] = {
	# NEW UPGRADES	
	Upgrades.ReduceShotDelayV1: {
		NAME: "Reduce Shot Delay Rate",
		DESCRIPTION: "-0.1 seconds from shot delay",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: -0.1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 4,
		INITIAL_PRICE: 12,
		CURRENT_PRICE: 12,
	},
	Upgrades.ReduceShotDelayV2: {
		NAME: "Reduce Shot Delay Rate V2",
		DESCRIPTION: "-0.15 seconds from shot delay",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: -0.15,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 9,
		INITIAL_PRICE: 50,
		CURRENT_PRICE: 50,
	},
	Upgrades.ReduceShotDelayV3: {
		NAME: "Reduce Shot Delay Rate V3",
		DESCRIPTION: "-0.3 seconds from shot delay",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: -0.3,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 200,
		CURRENT_PRICE: 200,
	},
	Upgrades.ReduceShotDelayV4: {
		NAME: "Reduce Shot Delay Rate V4",
		DESCRIPTION: "-0.5 seconds from shot delay",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: -0.5,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 1000,
		CURRENT_PRICE: 1000,
	},
	Upgrades.MaxLevelTimeV1: {
		NAME: "Max level time +1.25s",
		DESCRIPTION: "+1.25s seconds to level time",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.25,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 20,
		CURRENT_PRICE: 20,
	},
	Upgrades.MaxLevelTimeV2: {
		NAME: "Max level time +1s",
		DESCRIPTION: "+1s seconds to level time",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 90,
		CURRENT_PRICE: 90,
	},
	Upgrades.MaxLevelTimeV3: {
		NAME: "Max level time +0.5s",
		DESCRIPTION: "+0.5s seconds to level time",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 300,
		CURRENT_PRICE: 300,
	},
	Upgrades.PegDestoryedAddsLevelTimeV1: {
		NAME: "Peg destroyed adds level time +0.02s",
		DESCRIPTION: "+0.02s seconds to level time for each peg destoryed",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.02,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 80,
		CURRENT_PRICE: 80,
	},
	Upgrades.PegDestoryedAddsLevelTimeV2: {
		NAME: "Peg destroyed adds level time +0.05s",
		DESCRIPTION: "+0.05s seconds to level time for each peg destoryed",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.05,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 250,
		CURRENT_PRICE: 250,
	},
	Upgrades.PickUpRadiusV1: {
		NAME: "Money pickup radius increased",
		DESCRIPTION: "Money pickup radius increased",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 3,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 250,
		CURRENT_PRICE: 250,
	},
	Upgrades.BallsPickupRewardsV1: {
		NAME: "Balls can pick up rewards",
		DESCRIPTION: "Balls will pick up rewards with small radius",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 400,
		CURRENT_PRICE: 400,
	},
	Upgrades.BallPickupRadiusV1: {
		NAME: "Ball pickup radius increased",
		DESCRIPTION: "Balls pickup radius increased",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 3,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 80,
		CURRENT_PRICE: 80,
	},
	Upgrades.AttackDmgUpV1: {
		NAME: "Dmg +1",
		DESCRIPTION: "+1 Dmg per hit",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 4,
		INITIAL_PRICE: 5,
		CURRENT_PRICE: 5,
	},
	Upgrades.AttackDmgUpV2: {
		NAME: "Dmg +1.5",
		DESCRIPTION: "+1.5 Dmg per hit",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 45,
		CURRENT_PRICE: 45,
	},
	Upgrades.CritChanceV1: {
		NAME: "Crit Chance +10%",
		DESCRIPTION: "+10% Chance to cause crit dmg",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 2,
		INITIAL_PRICE: 120,
		CURRENT_PRICE: 120,
	},
	Upgrades.CritChanceV2: {
		NAME: "Crit Chance +15%",
		DESCRIPTION: "+15% Chance to cause crit dmg",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.15,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 2,
		INITIAL_PRICE: 250,
		CURRENT_PRICE: 250,
	},
	Upgrades.MaxBallBounceV1: {
		NAME: "Max Ball Bounce +1",
		DESCRIPTION: "Max times a ball can bounce +1",
		INITIAL_VALUE: 3,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 12,
		CURRENT_PRICE: 12,
	},
	Upgrades.MaxBallBounceV2: {
		NAME: "Max Ball Bounce +1",
		DESCRIPTION: "Max times a ball can bounce +1",
		INITIAL_VALUE: 3,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 3,
		INITIAL_PRICE: 50,
		CURRENT_PRICE: 50,
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
		INITIAL_PRICE: 1,
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
		INITIAL_PRICE: 2,
		CURRENT_PRICE: 2,
	},
	Upgrades.QuadurpleMoneyEarned: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Quadruple Money Earned",
		DESCRIPTION: "4x all money earned from prizes",
		INITIAL_VALUE: 3.0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 4,
		CURRENT_PRICE: 4,
	},
	Upgrades.MagicBallsOnPegHit: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Magic Balls on Peg Hit",
		DESCRIPTION: "+1% Chance ball turns into magic ball when hitting pegs",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.01,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 1,
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
		INITIAL_PRICE: 1,
		CURRENT_PRICE: 1,
	},
	
	Upgrades.ExtraCannon: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Extra Cannon",
		DESCRIPTION: "+1 additional cannon",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 2,
		INITIAL_PRICE: 5,
		CURRENT_PRICE: 5,
	},
	Upgrades.KeepMoneyOnPresstige: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Keep Money on Prestige",
		DESCRIPTION: "Keep +10% of money when prestiging",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 5,
		CURRENT_PRICE: 5,
	},

	Upgrades.BaseLevelRewardsUpX: {
		UPGRADE_PRESTIGE_TYPE: UpgradePrestigeType.Prestige,
		NAME: "Base Level Rewards Up",
		DESCRIPTION: "+x2 base reward values",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 2,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 2,
		CURRENT_PRICE: 2,
	},

	Upgrades.NewMachines: {
		NAME: "New Machines",
		DESCRIPTION: "+[$48 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 48,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 30000,
		CURRENT_PRICE: 30000,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.ShinyBalls: {
		NAME: "Shiny Balls",
		DESCRIPTION: "+[$24 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 24,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 10000,
		CURRENT_PRICE: 10000,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.VipLounge: {
		NAME: "VIP Lounge",
		DESCRIPTION: "+[$12 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 12,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 5000,
		CURRENT_PRICE: 5000,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.ComfySeats: {
		NAME: "More Comfortable Seats",
		DESCRIPTION: "+[$6 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 6,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 2400,
		CURRENT_PRICE: 2400,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.DecorUpgrade: {
		NAME: "Decor Upgrade",
		DESCRIPTION: "+[$3 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 3,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 800,
		CURRENT_PRICE: 800,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.FreeSnacks: {
		NAME: "Free Snacks",
		DESCRIPTION: "+[$1.5 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.5,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 150,
		CURRENT_PRICE: 150,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.ChanceBallRespawnsOnMissedPrize: {
		NAME: "Balls respawn on miss",
		DESCRIPTION: "+5% Chance that Ball will respawn on missed Prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.05,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 50,
		CURRENT_PRICE: 50,
	},
	Upgrades.BronzeBallsSpawnPercentage: {
		NAME: "Bronze Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Bronze Balls will spawn, bronze balls give +5x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20,
		INITIAL_PRICE: 400,
		CURRENT_PRICE: 400,
	},
	Upgrades.BronzeBallsGetPegBonus: {
		NAME: "Bronze Balls effect peg bonus",
		DESCRIPTION: "Bronze balls give +5x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 1000,
		CURRENT_PRICE: 1000,
	},
	Upgrades.SilverBallsSpawnPercentage: {
		NAME: "Silver Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Silver Balls will spawn, silver balls give +10x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20,
		INITIAL_PRICE: 2000,
		CURRENT_PRICE: 2000,
	},
	Upgrades.SilverBallsGetPegBonus: {
		NAME: "Silver Balls effect peg bonus",
		DESCRIPTION: "Silver balls give +10x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 4000,
		CURRENT_PRICE: 4000,
	},
	Upgrades.GoldBallsSpawnPercentage: {
		NAME: "Gold Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Gold Balls will spawn, gold balls give +25x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20,
		INITIAL_PRICE: 7500,
		CURRENT_PRICE: 7500,
	},
	Upgrades.GoldBallsGetPegBonus: {
		NAME: "Gold Balls effect peg bonus",
		DESCRIPTION: "Gold balls give +25x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 15000,
		CURRENT_PRICE: 15000,
	},
	Upgrades.DiamonBallsSpawnPercentage: {
		NAME: "Diamond Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Diamond Balls will spawn, diamond balls give +50x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20,
		INITIAL_PRICE: 25000,
		CURRENT_PRICE: 25000,
	},
	Upgrades.DiamondBallsGetPegBonus: {
		NAME: "Diamond Balls effect peg bonus",
		DESCRIPTION: "Diamond balls give +50x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 50000,
		CURRENT_PRICE: 50000,
	},
	Upgrades.PlatinumBallsSpawnPercentage: {
		NAME: "Platinum Balls have chance to spawn",
		DESCRIPTION: "+1.5% Chance that Platinum Balls will spawn, platinum balls give +100x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 20,
		INITIAL_PRICE: 100000,
		CURRENT_PRICE: 100000,
	},
	Upgrades.PlatBallsGetPegBonus: {
		NAME: "Platinum Balls effect peg bonus",
		DESCRIPTION: "Platinum balls give +100x prize",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1.0,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 1,
		INITIAL_PRICE: 200000,
		CURRENT_PRICE: 200000,
	},
	Upgrades.TokensCanSpawnPercentage: {
		NAME: "Prestige Tokens have chance to spawn",
		DESCRIPTION: "+2% Chance that Prestige Tokens will spawn as prizes",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.02,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 5,
		INITIAL_PRICE: 37500,
		CURRENT_PRICE: 37500,
	},
	Upgrades.MaxTokens: {
		NAME: "Prestige Tokens max +1",
		DESCRIPTION: "+1 Capacity to prestige tokens",
		INITIAL_VALUE: 3,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 30,
		INITIAL_PRICE: 250000,
		CURRENT_PRICE: 250000,
	},
	Upgrades.ChanceToSplitBallOnPegHit: {
		NAME: "Chance to Split Ball on Peg Hit",
		DESCRIPTION: "+0.15% Chance that ball will split on peg hit",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.0015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 150,
		CURRENT_PRICE: 150,
	},
	Upgrades.ChanceToSpawnBallOnPrizeClaim: {
		NAME: "Chance to Respawn Ball",
		DESCRIPTION: "+3% Chance that ball will respawn",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.03,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 8,
		INITIAL_PRICE: 125,
		CURRENT_PRICE: 125,
	},
	Upgrades.MaxRewardAmountPercentage: {
		NAME: "Max Reward +Percentage",
		DESCRIPTION: "+25% Max reward value for each level",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.25,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 200,
		CURRENT_PRICE: 200,
	},
	
	Upgrades.MinRewardColumns: {
		NAME: "Min Rewards Columns",
		DESCRIPTION: "Min amount of reward columns in game",
		INITIAL_VALUE: 2,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 6,
		INITIAL_PRICE: 75,
		CURRENT_PRICE: 75,
	},
	Upgrades.Customers: {
		NAME: "Customers",
		DESCRIPTION: "+[$0.5 / secs]",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.5,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 10,
		CURRENT_PRICE: 10,
		UPGRADE_TYPE: UpgradeType.MoneyPerSecond,
	},
	Upgrades.PegsCanHavePrizesSpawnPercetange: {
		NAME: "Pegs Can Have Prizes",
		DESCRIPTION: "+1.5% Chance pegs have prizes",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.015,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 50,
		INITIAL_PRICE: 100,
		CURRENT_PRICE: 100,
	},
	Upgrades.PegsPrizeAmount: {
		NAME: "Max Peg prize amount",
		DESCRIPTION: "+3% max prize amount for pegs",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 0.03,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 175,
		CURRENT_PRICE: 175,
	},
	Upgrades.PrizesCanBeClaimedXTimes: {
		NAME: "Prizes can be claimed multiple times",
		DESCRIPTION: "+1 a prize can be claimed",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 15,
		INITIAL_PRICE: 400,
		CURRENT_PRICE: 400,
	},
	Upgrades.PrizesCanBeClaimedXTimesPerPeg: {
		NAME: "Peg Prizes can be claimed multiple times",
		DESCRIPTION: "+1 a peg prize can be claimed",
		INITIAL_VALUE: 0,
		VALUE_PER_LEVEL: 1,
		CURRENT_LEVEL: 0,
		MAX_LEVEL: 10,
		INITIAL_PRICE: 500,
		CURRENT_PRICE: 500,
	},
	
}




func debug_values():
	money = 1000000
	tokens = 100


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	if EngineDebugger.is_active():
		debug_values()

func is_upgrade_money_per_second(upgrade: Upgrades) -> bool:
	return upgrade_data.get(upgrade).get_or_add(UPGRADE_TYPE, UpgradeType.Gameplay) == UpgradeType.MoneyPerSecond

func calculate_per_second_money() -> float:
	var sum: float = 0
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
	if money < get_upgrade_next_cost(upgrade) && !is_upgrade_prestige_upgrade(upgrade):
		return
		
	if tokens < get_upgrade_next_cost(upgrade) && is_upgrade_prestige_upgrade(upgrade):
		return
	if get_upgrade_current_level(upgrade) >= get_upgrade_max_level(upgrade):
		return
	if is_upgrade_prestige_upgrade(upgrade):
		tokens-= get_upgrade_next_cost(upgrade)
	else:
		money-= get_upgrade_next_cost(upgrade)

	upgrade_data.get(upgrade).set(CURRENT_LEVEL, upgrade_data.get(upgrade).get_or_add(CURRENT_LEVEL, 0) + 1)
	save_game()
	
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
var save_countdown = 20.0
var game_speed_modifier: float = 1.0
func _process(delta: float) -> void:
	
	Engine.physics_ticks_per_second = max(60 * game_speed_modifier, 1.0)
	game_dt = delta * game_speed_modifier
	countdown-= delta
	save_countdown-= delta

	if countdown <=0:
		countdown = 1.0
		money+= calculate_per_second_money()

	if save_loaded && save_countdown <= 0:
		save_countdown = 20.0
		save_game()

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

func cancel_prestige_scene():
	change_to_upgrades_scene()

func confirm_prestige_scene():
	level = 1
	Game.reset_all_upgrades()
	if has_upgrade(Game.Upgrades.KeepMoneyOnPresstige):
		Game.money = Game.money * get_upgrade_current_value(Game.Upgrades.KeepMoneyOnPresstige)
	else:
		Game.money = 0
		
	change_to_pachinko_scene()

func change_to_prestige_scene():
	change_scene_request.emit(GameRoot.Scene.Prestige)


func get_current_level_base_reward() -> float:

	var my_array: Array[float] = [1,2,3,4,5,6,7,8]
	var weights = PackedFloat32Array([8, 7, 6, 5, 4, 3, 2, 1])

# Prints one of the four elements in `my_array`.
# It is more likely to print "four", and less likely to print "one".


	var value: float = float(my_array[rng.rand_weighted(weights)]) * 0.25
	if has_upgrade(Game.Upgrades.BaseLevelRewardsUpX):
		return value * max(get_upgrade_current_value(Game.Upgrades.BaseLevelRewardsUpX), 1)
	return value

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

func format_number_precise(value: float, sci_threshold: int = 1000000000000000) -> String:
	var suffixes = ["", "K", "M", "B", "T"]
	var magnitude = 0
	
	if value < 1000:
		return "%0.2f" % value

	# Check if we should use scientific notation
	if value >= sci_threshold:
		return format_scientific(value)

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






# UPGRADES compute functions
var min_bounce_count: int = 2
func get_max_bounce_count() -> int:
	return min_bounce_count + Game.get_upgrade_current_value(Game.Upgrades.MaxBallBounceV1) + Game.get_upgrade_current_value(Game.Upgrades.MaxBallBounceV2)

var min_dmg: float = 1
func get_ball_base_dmg() -> float:
	var dmg_up:= 1.0
	if Game.should_upgrade_be_triggered_chance(Game.Upgrades.CritChanceV1) || Game.should_upgrade_be_triggered_chance(Game.Upgrades.CritChanceV2):
		dmg_up = 1.5
	
	
	return dmg_up * min_dmg + Game.get_upgrade_current_value(Game.Upgrades.AttackDmgUpV1) + Game.get_upgrade_current_value(Game.Upgrades.AttackDmgUpV2)


var min_level_time: float = 16.5
var time_left: float
func get_start_level_time() -> float:
	
	return min_level_time + (Game.get_upgrade_current_value(Game.Upgrades.MaxLevelTimeV1) 
		+ Game.get_upgrade_current_value(Game.Upgrades.MaxLevelTimeV2)
		+ Game.get_upgrade_current_value(Game.Upgrades.MaxLevelTimeV3)
		)

var initial_firerate: float = 5.0
func get_cannon_firerate() -> float:
	return initial_firerate + (
		Game.get_upgrade_current_value(Game.Upgrades.ReduceShotDelayV1) 
		+ Game.get_upgrade_current_value(Game.Upgrades.ReduceShotDelayV2)
		+ Game.get_upgrade_current_value(Game.Upgrades.ReduceShotDelayV3)
		+ Game.get_upgrade_current_value(Game.Upgrades.ReduceShotDelayV4)
	)


func get_peg_add_time_amount() -> float:
	return get_upgrade_current_value(Game.Upgrades.PegDestoryedAddsLevelTimeV1) + get_upgrade_current_value(Game.Upgrades.PegDestoryedAddsLevelTimeV2)

# SAVE STUFF
var path: String = "user://savegame.save"

func has_save() -> bool:
	return FileAccess.file_exists(path)

var current_version: float = 0.04
func save_game():
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	save_countdown = 50.0
	if save_file == null:
		printerr("Error opening save file for writing")
		return

	var dict: Dictionary = {
		"save_version": current_version,
		"upgrades": upgrade_data,
		"money": money,
		"tokens": tokens,
		"level": level,
		"settings": {
			"sfx": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Sfx")),
			"music": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music")),
			"master": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master")),
			"disabled_transition": disabled_transition,
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



	if node_data.get("save_version") == current_version:
		var raw_upgrades: Dictionary = node_data["upgrades"]
		for key in raw_upgrades:
			var int_key = int(key)  # JSON keys are strings, convert to int first
			var upgrade_enum = int_key as Upgrades  # Convert int to enum
			upgrade_data[upgrade_enum].set(CURRENT_LEVEL, raw_upgrades[key].get(CURRENT_LEVEL))
		money = node_data["money"]
		tokens = node_data["tokens"]
		if node_data.has("level"):
			level = node_data.get("level")
	else:
		print("OLD SAVE FILE")

	if node_data.has("settings"):
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sfx"), node_data.get("settings").get("sfx"))
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), node_data.get("settings").get("music"))
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), node_data.get("settings").get("master"))
		var value = node_data.get("settings").get("disabled_transition")
		if value != null:
			disabled_transition = value
	print("Game loaded successfully!")
