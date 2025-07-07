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

var ball_type: = BallType.Normal

var stuck_threshold = 10.0  # How low velocity needs to be to consider "stuck"
var stuck_time = 0.0
var stuck_check_duration = 1.0  # How long to wait before considering it stuck
var bump_force = 200.0

var id: int = -1

@onready var sprite: Sprite2D= $Sprite2D

func spawn():
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
		sprite.modulate = Color.SILVER
		
	elif Game.should_upgrade_be_triggered_chance(Game.Upgrades.BronzeBallsSpawnPercentage):
		ball_type = BallType.Bronze
		sprite.modulate = Color.GOLDENROD

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
	
	
