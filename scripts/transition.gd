class_name Transition extends Control


@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/Label


const TRANSITION_TIME = 0.4

func start_transition(color: Color, name: String, hold_time: float = 0.8) -> Signal:
	color_rect.color = color
	var tween = create_tween()
	mouse_filter = Control.MOUSE_FILTER_STOP
	tween.tween_property(color_rect.material, 'shader_parameter/circle_size', 0.0, TRANSITION_TIME)
	label.text = name
	await get_tree().create_timer(hold_time).timeout
	tween = create_tween()
	label.show()
	label.scale = Vector2.ZERO
	tween.set_ease(Tween.EaseType.EASE_OUT)
	tween.set_trans(Tween.TransitionType.TRANS_ELASTIC)
	tween.tween_property(label, 'scale', Vector2.ONE, 0.8)
	
	await tween.finished
	await get_tree().create_timer(hold_time).timeout

	return tween.finished
	
	
func end_transition():
	var tween = create_tween()
	tween.tween_property(label, 'scale', Vector2.ZERO, 0.2)
	await tween.finished
	await get_tree().create_timer(0.4).timeout
	tween = create_tween()
	tween.tween_property(color_rect.material, 'shader_parameter/circle_size', 0.8, TRANSITION_TIME)
	await tween.finished
	label.hide()
