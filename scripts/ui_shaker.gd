

# consider using the [AnimationPlayer] instead of [Tween] to setup animations in editor instead code
class_name Motion
extends Control

## The [Motion] script is a wrapper around [Tween] that allows animation intensity changes anytime.
## The effect is applied via [add_motion] function or via signals [trigger_signals] to [targets].
## Properties in motion will start returning to the original value over time.
## [br][br]
## Base script for all motion components.
## Override [_get_target_original_value] and [_motion_transform] to setup custom properties motion.
## Set export variables to get a desired effect variation.
## [br][br]
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@export var target: Control


@export_category("Motion")
@export var min_motion_factor: float = 1.0
@export var max_motion_factor: float = 1.1
## If set to 0, will use max motion factor when calling [add_motion].
@export var add_motion_default: float = 0.0
@export var motion_duration: float = 1.0


@export_category("Tween")
## See: https://www.reddit.com/r/godot/comments/14gt180
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_ELASTIC
@export var ease_type: Tween.EaseType = Tween.EaseType.EASE_OUT

var motion_factor: float = min_motion_factor

var _original_target_values: Dictionary = {}
var _motion_tween: Tween = null

var _sign: int = 1
@export var max_rotation_degrees: float = 3.0


func _ready() -> void:

	_original_target_values["scale"] = target.scale
	_original_target_values["rotation"] = target.rotation

	
func add_motion(motion_factor_increment: float = add_motion_default) -> void:
	if motion_factor_increment == 0.0:
		motion_factor_increment = max_motion_factor

	if motion_factor_increment > 0:
		motion_factor = min(max_motion_factor, motion_factor + motion_factor_increment)
	else:
		motion_factor = max(min_motion_factor, motion_factor + motion_factor_increment)
	if _motion_tween != null:
		_motion_tween.kill()
	_motion_tween = create_tween().set_trans(transition_type).set_ease(ease_type)
	_motion_tween.tween_method(
		_motion_tween_method, motion_factor, min_motion_factor, motion_duration
	)


	


func _motion_tween_method(factor: float) -> void:
	motion_factor = factor
	target.scale = _original_target_values["scale"] * motion_factor
	# normalized_factor goes from 0 to 1 regardless of min and max motion factor
	var normalized_factor: float = (
		(motion_factor - min_motion_factor) / (max_motion_factor - min_motion_factor)
	)
	var rotation_offset: float = _sign * deg_to_rad(normalized_factor * max_rotation_degrees)
	target.rotation = _original_target_values["rotation"] - rotation_offset
