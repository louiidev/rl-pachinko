class_name Peg
extends StaticBody2D


@onready var sprite: Sprite2D = $Sprite2D

@onready var area: Area2D = $Area2D
@onready var shake: Shake = $Shake

@onready var prize_label: Label = $PrizeLabel


var claimed_amount: int = 0
var prize: int = 0
var prize_disabled = false

var colors: Array = [
	Color.WHITE, 
	Color.NAVY_BLUE, 
	Color.AQUAMARINE, 
	Color.BLUE_VIOLET, 
	Color.FOREST_GREEN, 
	Color.SALMON, 
	Color.PLUM, 
	Color.ORANGE,
	Color.WEB_MAROON,
	Color.AQUA,
	Color.GOLD
]

func on_ball_hit(body: Node):
	if body.get_script().get_global_name() == "Ball":
		var ball: Ball = body
		shake.apply_shake(ball.linear_velocity.length() * 0.008)
		if ball.linear_velocity.length() > 120:
			ParticleManager.spawn_hit_particle(global_position, (global_position - body.global_position).normalized(), sprite.modulate)
		
		var max_claim_amount = 1 + Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimesPerPeg)
		if prize > 0 && claimed_amount < max_claim_amount:
			PopupManager.new_money_text(prize,global_position)
			claimed_amount+= 1
			sprite.modulate = colors[max(Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimesPerPeg) - claimed_amount, 0)]
#			# add a timeout or something to prevent multiple hits in succession
			Game.money_this_game+= prize
			Game.money+= prize
			if claimed_amount >= max_claim_amount:
				prize_label.hide()
				sprite.modulate = colors[0]
				prize_disabled = true
				await get_tree().create_timer(0.5).timeout
				prize_disabled = false
			
				

func _ready() -> void:
	area.body_entered.connect(on_ball_hit)

func setup():
	prize_label.hide()
	claimed_amount = 0
	sprite.modulate = colors[0]
	prize = 0
	prize_disabled = false
	if Game.has_upgrade(Game.Upgrades.PegsCanHavePrizesSpawnPercetange):
		var actual_spawn_percentage: float = Game.get_upgrade_current_value(Game.Upgrades.PegsCanHavePrizesSpawnPercetange)
		if Game.rng.randf_range(0, 1) < actual_spawn_percentage:
			var level_reward = Game.get_current_level_base_reward() + ceili(Game.get_current_level_base_reward() * Game.get_upgrade_current_value(Game.Upgrades.PegsCanHavePrizesSpawnPercetange))
			prize = Game.rng.randf_range(1, level_reward)
			prize_label.text = "$" +str(prize)
			prize_label.show()
			sprite.modulate = colors[max(Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimesPerPeg) - claimed_amount, 0)]
			
