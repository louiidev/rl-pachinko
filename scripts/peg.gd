class_name Peg
extends AnimatableBody2D


@onready var sprite: Sprite2D = $Sprite2D

@onready var area: Area2D = $Area2D
@onready var shake: Shake = $Shake

@onready var prize_label: Label = $PrizeLabel



signal request_peg_prize(prize: float, position: Vector2)
signal ball_hit_peg(ball_g_position: Vector2, volume: float, peg_dead: bool)

var claimed_amount: int = 0
var prize: float = 0
var prize_disabled = false
var max_claim_amount: int
var peg_health: float = 3
var original_peg_health: float = 3
var peg_max_health: float

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

@onready var mask_container: Sprite2D = $Sprite2D/MaskContainer

func _ready() -> void:
	var health_modifier = min(Game.level, 15)
	peg_max_health = peg_health * health_modifier
		
	peg_health = peg_max_health
	area.body_entered.connect(on_ball_hit)
	
	mask_container.material.set_shader_parameter("fill_percentage", 0.0)
	#mask_container.material = mask_container.material.duplicate()

func is_prize_active() -> bool:
	return prize > 0 && claimed_amount < max_claim_amount

var already_hit_ids: Array[int] = []

func on_ball_hit(body: Node):
	if body.get_script().get_global_name() == "Ball":
		var ball: Ball = body


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

			already_hit_ids.push_back(ball.id)
			if Game.should_upgrade_be_triggered_chance(Game.Upgrades.MagicBallsOnPegHit):
				ball.set_magic_ball()



		ball.update_count()
		dmg_peg(ball.get_ball_dmg())
		ball_hit_peg.emit(ball.position, volume_db, peg_health <= 0)



		shake.apply_shake(velocity * 0.008)
		if velocity > 120:
			ParticleManager.spawn_hit_particle(global_position, (global_position - body.global_position).normalized(), sprite.modulate)

		if prize != 0 && claimed_amount < max_claim_amount:
			var reward_amount:= Ball.get_ball_peg_upgrade_amount(ball.ball_type, ball.ball_variant, prize)
			if prize > 0:
				request_peg_prize.emit(prize, global_position)
			
			claimed_amount+= 1
			sprite.modulate = colors[clamp(Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimesPerPeg) - claimed_amount, 0, colors.size() - 1)]
#           # add a timeout or something to prevent multiple hits in succession
			

			if claimed_amount >= max_claim_amount:
				if Game.has_upgrade(Game.Upgrades.PegsAlwaysRespawn) && prize > 0:
					set_prize()
				else:
					prize_label.hide()
					sprite.modulate = colors[0]
					prize_disabled = true
					await get_tree().create_timer(0.8).timeout
					prize_disabled = false




func dmg_peg(dmg: float):
	peg_health-= dmg
	if peg_health <= 0.0:
		#        SPAWN PRIZE
		queue_free()
		ParticleManager.spawn_splash_particle(global_position)
	else:
		var ratio = 1.0 - (float(peg_health) / float(peg_max_health))
		mask_container.material.set_shader_parameter("fill_percentage", ratio + 0.05)







func set_prize():
		claimed_amount = 0

		prize = float(Game.rng.randi_range(1, Game.level + ceili(1 * Game.Upgrades.PegsPrizeAmount)))
		prize_label.text = "$" +str(prize)
		prize_label.show()
		sprite.modulate = colors[clamp(Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimesPerPeg) - claimed_amount, 0, colors.size() - 1)]
		var health_modifier = min(Game.level, 15)
		peg_max_health = peg_health * health_modifier * max_claim_amount
		peg_health = peg_max_health
		print("SET PEG HEALTH TO ", peg_health)

func setup():
	already_hit_ids = []
	prize_label.hide()
	claimed_amount = 0
	sprite.modulate = colors[0]
	prize = 0
	prize_disabled = false

	if Game.should_upgrade_be_triggered_chance(Game.Upgrades.PegsCanHavePrizesSpawnPercetange):
		set_prize()
