class_name Cannon

extends Sprite2D

var min_rotation: float
@export var max_rotation: float = 70
var direction = 1
var rotation_speed = 50.0 

@onready var cannon_spawn_point: Marker2D = $SpawnPoint

func _ready() -> void:
	min_rotation = -max_rotation
	
	
var move_direction = 1
func _physics_process(delta: float) -> void:

	if Game.has_upgrade(Game.Upgrades.CannonMovesHorizontally):
		if move_direction == 1 && position.x > 500:
			move_direction = -1
		elif move_direction == -1 && position.x < -500:
			move_direction = 1
		
		position+= delta * Vector2(move_direction, 0) * 50
	
	rotation_degrees += rotation_speed * direction * delta
	if rotation_degrees >= max_rotation:
		rotation_degrees = max_rotation
		direction = -1
	elif rotation_degrees <= min_rotation:
		rotation_degrees = min_rotation
		direction = 1
