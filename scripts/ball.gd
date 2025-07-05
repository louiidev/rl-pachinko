class_name Ball
extends  RigidBody2D

var stuck_threshold = 10.0  # How low velocity needs to be to consider "stuck"
var stuck_time = 0.0
var stuck_check_duration = 1.0  # How long to wait before considering it stuck
var bump_force = 200.0


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
	
	
