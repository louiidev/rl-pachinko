extends Sprite2D

var parent: Node2D
var parent_offset: Vector2

func _ready() -> void:
	parent = get_parent()
	parent_offset = position
	set_as_top_level(true)
	global_position = parent.global_position + parent_offset
	z_index = -1
	

func _physics_process(delta: float) -> void:
	global_position = parent.global_position + parent_offset
