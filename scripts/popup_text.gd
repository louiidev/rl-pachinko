extends Node2D


func _ready() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 2.0)
	await tween.finished
	self.free()
func _process(delta: float) -> void:
	position+= Vector2.UP * delta * 140
