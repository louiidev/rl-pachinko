class_name MoneyDrop
extends Node2D


@onready var area_2d: Area2D = $Area2D
@onready var label: Label = $Label

var collected: bool = false
var value: float = 1
@export var speed:float = 20

var original_color: Color

func _ready() -> void:
	area_2d.mouse_entered.connect(collect)
	var _tween: Tween
	original_color = label.modulate
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_ELASTIC)
	
	var collision_shape: CollisionShape2D = area_2d.get_node("CollisionShape2D")
	var circle: CircleShape2D = collision_shape.shape
	circle.radius+= Game.get_upgrade_current_value(Game.Upgrades.PickUpRadiusV1)


func set_value(amount: float = 1) -> void:
	var new_amount = amount
	if amount > 0:
		if Game.has_upgrade(Game.Upgrades.QuadurpleMoneyEarned):
			new_amount = amount * 4
		elif Game.has_upgrade(Game.Upgrades.TripleMoneyEarned):
			new_amount = amount * 3
		elif Game.has_upgrade(Game.Upgrades.DoubleMoneyEarned):
			new_amount = amount * 2
	
	
	value=new_amount
	get_node("Label").text = "$" + Game.format_number_precise(new_amount)

func collect() -> void:
	area_2d.mouse_entered.disconnect(collect)
	label.modulate = Color.WHITE
	
	follow_delay()

func follow_delay():
	Game.add_money(value)
	
	await get_tree().create_timer(0.25).timeout
	collected = true
	label.modulate = original_color


var tween: Tween
func _process(_delta: float) -> void:
	var delta = Game.game_dt
	if collected:

		var mouse_pos: Vector2 = get_global_mouse_position()
		# Better approach - ease the distance-based interpolation:
		var distance = global_position.distance_to(mouse_pos)
		var normalized_distance = clamp(distance / 1000.0, 0.0, 1.0)  # Adjust 1000.0 as needed
		var eased_factor = ease(1.0, normalized_distance) * delta * speed

		global_position = global_position.lerp(mouse_pos, eased_factor)
		if global_position.distance_to(mouse_pos) <= 5 && tween == null:
			tween = create_tween()
			tween.tween_property(self, "scale", Vector2.ZERO, 0.4)
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_ELASTIC)
			await tween.finished
			queue_free()
