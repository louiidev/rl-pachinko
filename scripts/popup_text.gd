class_name PopupText extends Node2D

var tween: Tween
func _ready() -> void:
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 2.0)
	await tween.finished
	self.queue_free()
func _process(_delta: float) -> void:
	
	position+= Vector2.UP * Game.game_dt * 140



func change_scene():
	hide.call_deferred()
	tween.finished.emit()
	
