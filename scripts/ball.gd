class_name Ball
extends RigidBody2D

enum BallType {
	Normal,
	Bronze,
	Silver,
	Gold,
	Diamond,
	Platinum
}

enum BallVariant {
	Normal,
	Magic,
	Mini,
}

@export var mini_ball_physics_mat: PhysicsMaterial


var glow_color: Color = Color(1.33, 1.33, 1.33, 1.0)

var ball_type: = BallType.Normal
var ball_variant = BallVariant.Normal

var stuck_threshold = 10.0  # How low velocity needs to be to consider "stuck"
var stuck_time = 0.0
var stuck_check_duration = 1.0  # How long to wait before considering it stuck
var bump_force = 200.0


var max_bounce: int = 3
var current_bounce_count: int

var id: int = -1

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var magic_particles: GPUParticles2D = $MagicParticles


func _ready() -> void:
	magic_particles.emitting = false
	current_bounce_count = 0
	max_bounce = Game.get_max_bounce_count()
	#physics_material_override = mini_ball_physics_mat

func update_count():
	current_bounce_count+= 1
	if current_bounce_count >= max_bounce:
		ParticleManager.spawn_splash_particle(global_position)
		queue_free()

func set_variant(variant: BallVariant):
	self.ball_variant = variant
	match variant:
		BallVariant.Magic:
			set_magic_ball()
		BallVariant.Mini:
			set_mini_ball()


func set_mini_ball():
	sprite.scale = Vector2(0.5, 0.5)
	shape.scale =  Vector2(0.5, 0.5)
	physics_material_override = mini_ball_physics_mat


func set_magic_ball():
	magic_particles.emitting = true


func get_ball_dmg() -> float:
	return Game.get_ball_base_dmg()


func spawn_menu_ball():
	position = Vector2(Game.rng.randf_range(-550, 550), 0)
	ball_type = Game.rng.randi_range(0, BallType.size() - 1)
	ball_variant = Game.rng.randi_range(0, BallVariant.size() - 1)
	set_variant(ball_variant)
	var scale:= Game.rng.randf_range(0.4, 3.0)
	sprite.scale = Vector2(scale, scale)
	shape.scale =  Vector2(scale, scale)
	physics_material_override = mini_ball_physics_mat

	physics_material_override = mini_ball_physics_mat
	set_glow()



	match ball_type:
		BallType.Platinum:
			sprite.modulate = Color.MEDIUM_PURPLE
		BallType.Diamond:
			sprite.modulate = Color.LIGHT_SKY_BLUE
		BallType.Gold:
			sprite.modulate = Color.GOLD
		BallType.Silver:
			sprite.modulate = Color.SNOW
		BallType.Bronze:
			sprite.modulate = Color.GOLDENROD




func set_glow():
	if ball_type != BallType.Normal || ball_variant == BallVariant.Magic:
		sprite.self_modulate = glow_color
		if ball_type == BallType.Platinum:
			sprite.self_modulate = Color(1.6, 1.6, 1.6)


func spawn(variant: BallVariant = BallVariant.Normal):
	if Game.should_upgrade_be_triggered_chance(Game.Upgrades.PlatinumBallsSpawnPercentage):
		ball_type = BallType.Platinum
		sprite.modulate = Color.MEDIUM_PURPLE
	elif Game.should_upgrade_be_triggered_chance(Game.Upgrades.DiamonBallsSpawnPercentage):
		ball_type = BallType.Diamond
		sprite.modulate = Color.LIGHT_SKY_BLUE
	elif Game.should_upgrade_be_triggered_chance(Game.Upgrades.GoldBallsSpawnPercentage):
		ball_type = BallType.Gold
		sprite.modulate = Color.GOLD
	elif Game.should_upgrade_be_triggered_chance(Game.Upgrades.SilverBallsSpawnPercentage):
		ball_type = BallType.Silver
		sprite.modulate = Color.SNOW

	elif Game.should_upgrade_be_triggered_chance(Game.Upgrades.BronzeBallsSpawnPercentage):
		ball_type = BallType.Bronze
		sprite.modulate = Color.GOLDENROD

	set_glow()
	set_variant(variant)

func _process(delta):
	var current_velocity = linear_velocity.length()

	if current_velocity < stuck_threshold:
		stuck_time += delta

		if stuck_time >= stuck_check_duration:
			give_bump()
			stuck_time = 0.0  # Reset timer
	else:
		stuck_time = 0.0  # Reset if moving again

func give_bump():
	# Random direction bump
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	apply_central_impulse(random_direction * bump_force)


static func get_ball_variant_upgrade_amount(ball_variant: BallVariant, reward_amount: float) -> float:
	if ball_variant == BallVariant.Magic:
		return reward_amount * 2

	return reward_amount

static func get_ball_upgrade_amount(ball_type: BallType, ball_variant: BallVariant, reward_amount: float) -> float:
	match ball_type:
		Ball.BallType.Bronze:
			return get_ball_variant_upgrade_amount(ball_variant, reward_amount * 5)
		Ball.BallType.Silver:
			return get_ball_variant_upgrade_amount(ball_variant, reward_amount * 10)
		Ball.BallType.Gold:
			return get_ball_variant_upgrade_amount(ball_variant, reward_amount * 25)
		Ball.BallType.Diamond:
			return get_ball_variant_upgrade_amount(ball_variant, reward_amount * 50)
		Ball.BallType.Platinum:
			return get_ball_variant_upgrade_amount(ball_variant, reward_amount * 100)

	return get_ball_variant_upgrade_amount(ball_variant, reward_amount)


static func get_ball_peg_upgrade_amount(ball_type: BallType, ball_variant: BallVariant, reward_amount: float) -> float:
	match ball_type:
		Ball.BallType.Bronze:
			if Game.has_upgrade(Game.Upgrades.BronzeBallsGetPegBonus):
				return get_ball_upgrade_amount(ball_type, ball_variant, reward_amount)
		Ball.BallType.Silver:
			if Game.has_upgrade(Game.Upgrades.SilverBallsGetPegBonus):
				return get_ball_upgrade_amount(ball_type, ball_variant, reward_amount)
		Ball.BallType.Gold:
			if Game.has_upgrade(Game.Upgrades.GoldBallsGetPegBonus):
				return get_ball_upgrade_amount(ball_type, ball_variant, reward_amount)
		Ball.BallType.Diamond:
			if Game.has_upgrade(Game.Upgrades.DiamonBallsSpawnPercentage):
				return get_ball_upgrade_amount(ball_type, ball_variant, reward_amount)
		Ball.BallType.Platinum:
			if Game.has_upgrade(Game.Upgrades.PlatBallsGetPegBonus):
				return get_ball_upgrade_amount(ball_type, ball_variant, reward_amount)

	return reward_amount
