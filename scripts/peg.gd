class_name Peg
extends StaticBody2D


@onready var sprite: Sprite2D = $Sprite2D

@onready var area: Area2D = $Area2D
@onready var shake: Shake = $Shake

@onready var prize_label: Label = $PrizeLabel


signal ball_hit_peg(ball_g_position: Vector2, )

var claimed_amount: int = 0
var prize: int = 0
var prize_disabled = false
var max_claim_amount: int


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
	Color.GOLD,
	Color.SPRING_GREEN,
]

func is_prize_active() -> bool:
	return prize > 0 && claimed_amount < max_claim_amount

var already_hit_ids: Array[int] = []

func on_ball_hit(body: Node):
	if body.get_script().get_global_name() == "Ball":
		var ball: Ball = body
		
				# Normalize to dB volume
		var volume_db = 0.0  # default normal volume
		var velocity: float = ball.linear_velocity.length()
		if velocity >= 700:
			# High volume: 0 to +6 dB for speeds 700+
			volume_db = lerp(0.0, 6.0, min((velocity - 700) / 300.0, 1.0))
		elif velocity >= 400:
			# Normal volume: -6 to 0 dB for speeds 400-700
			volume_db = lerp(-6.0, 0.0, (velocity - 400) / 300.0)
		else:
			# Low volume: -20 to -6 dB for speeds below 400
			volume_db = lerp(-20.0, -6.0, velocity / 400.0)
		
		if !prize_disabled && !already_hit_ids.has(ball.id):
			ball_hit_peg.emit(ball.position, volume_db)
			already_hit_ids.push_back(ball.id)
			if Game.should_upgrade_be_triggered_chance(Game.Upgrades.MagicBallsOnPegHit):
				ball.set_magic_ball()
			
				
	
	

		shake.apply_shake(velocity * 0.008)
		if velocity > 120:
			ParticleManager.spawn_hit_particle(global_position, (global_position - body.global_position).normalized(), sprite.modulate)
		
		if prize != 0 && claimed_amount < max_claim_amount:
			var reward_amount:= Ball.get_ball_peg_upgrade_amount(ball.ball_type, ball.ball_variant, prize)
			if prize > 0:
				PopupManager.new_money_text(reward_amount, global_position)
			else:
				PopupManager.negative_money_text(reward_amount, global_position)
			claimed_amount+= 1
			sprite.modulate = colors[clamp(Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimesPerPeg) - claimed_amount, 0, colors.size() - 1)]
#			# add a timeout or something to prevent multiple hits in succession
			Game.add_money(reward_amount)

			if claimed_amount >= max_claim_amount:
				if Game.has_upgrade(Game.Upgrades.PegsAlwaysRespawn) && prize > 0:
					set_prize()
				else:
					prize_label.hide()
					sprite.modulate = colors[0]
					prize_disabled = true
					await get_tree().create_timer(0.8).timeout
					prize_disabled = false
				
				

func _ready() -> void:
	area.body_entered.connect(on_ball_hit)
	max_claim_amount = 1 + Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimesPerPeg)


func set_prize():
		claimed_amount = 0
		var level_reward = Game.get_current_level_base_reward() + ceili(Game.get_current_level_base_reward() * Game.get_upgrade_current_value(Game.Upgrades.PegsCanHavePrizesSpawnPercetange))
		prize = Game.rng.randf_range(1, level_reward)
		prize_label.text = "$" +str(prize)
		prize_label.show()
		sprite.modulate = colors[clamp(Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimesPerPeg) - claimed_amount, 0, colors.size() - 1)]
	
func setup():
	already_hit_ids = []
	prize_label.hide()
	claimed_amount = 0
	sprite.modulate = colors[0]
	prize = 0
	prize_disabled = false
	
	if Game.should_upgrade_be_triggered_chance(Game.Upgrades.PegsCanHavePrizesSpawnPercetange):
		set_prize()
	elif Game.should_negative_upgrade_be_triggered_chance(Game.Upgrades.LessNegativePegs):
		prize = Game.rng.randf_range(-Game.base_level_reward, -1)
		prize_label.text = "-$" +str(abs(prize))
		prize_label.show()
		sprite.modulate = Color.RED
		prize_label.modulate = Color.RED
