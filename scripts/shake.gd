class_name Shake
extends Node2D

@export var random_strength_range: float = 10
@export var shake_fade: float = 10

@export var node_to_shake: Node2D

var original_g_position

var rng = RandomNumberGenerator.new()
var shake_strength: float

func _ready() -> void:
	original_g_position = node_to_shake.global_position
	

func apply_shake(addition: float = 0.0):
	shake_strength = random_strength_range + addition 
	pass
	
	
func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		node_to_shake.global_position = original_g_position + random_offset()
		if shake_strength <= 0:
			node_to_shake.global_position = original_g_position
		

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
