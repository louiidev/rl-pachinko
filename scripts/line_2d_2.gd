class_name Direction extends Line2D



	
var gravity: Vector2
func _ready() -> void:
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity_vector") * ProjectSettings.get_setting("physics/2d/default_gravity")
	
	
func update_trajectory(start_pos: Vector2, delta: float, velocity: Vector2, max_points: int):
	clear_points()
	var pos = start_pos
	var vel = global_transform * velocity
	for i in max_points:
		add_point(pos)
		vel.y += gravity.y * delta
		pos += vel * delta
		
