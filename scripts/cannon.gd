class_name Cannon

extends Sprite2D

var min_rotation: float
@export var max_rotation: float = 70
var direction = 1
var rotation_speed = 50.0 

func _ready() -> void:
	min_rotation = -max_rotation
	
	
func _physics_process(delta: float) -> void:
	
	rotation_degrees += rotation_speed * direction * delta
	if rotation_degrees >= max_rotation:
		rotation_degrees = max_rotation
		direction = -1
	elif rotation_degrees <= min_rotation:
		rotation_degrees = min_rotation
		direction = 1
