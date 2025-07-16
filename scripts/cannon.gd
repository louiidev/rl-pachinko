class_name Cannon

extends Sprite2D

var min_rotation: float
@export var max_rotation: float = 90
var direction = 1
var rotation_speed = 50.0

var cannon_indicator_size: float = 14
var cannon_max_indicator_size: float = 60

@onready var cannon_spawn_point: Marker2D = $SpawnPoint

var circle_arc_end: float = 0.0
func on_fire():
	var tween = create_tween()
	
	tween.tween_property(self, "circle_arc_end", 0, 0.3)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	tween_scale_indicator(Game.get_cannon_firerate() - 0.3)

func tween_scale_indicator(tween_time: float = Game.get_cannon_firerate()):
	var tween = create_tween()
	tween.tween_property(self, "circle_arc_end", 360, tween_time)
	

var arr: PackedVector2Array = [Vector2(0,0), Vector2(20,20), Vector2(50.5,50.5)]
func _draw() -> void:
	var radius = 20.0
	draw_arc(Vector2(0, 0), radius, deg_to_rad(90.0), deg_to_rad(90 + 360), 100, Color.BLACK, 10.0 +  10)
	draw_arc(Vector2(0, 0), radius, deg_to_rad(90.0), deg_to_rad(90 + circle_arc_end), 100, Color.WHITE, 10.0)
	draw_polygon(arr, [Color.WHITE])
	
func _ready() -> void:
	min_rotation = -max_rotation
	tween_scale_indicator()

var move_direction = 1
func _process(_delta: float) -> void:
	var rotation_deg: float = rotation_degrees
	var velocity: Vector2 = Vector2.from_angle(deg_to_rad(rotation_deg + 90)) * (750 + (abs(rotation_deg) * 0.5))
	queue_redraw()
	look_at(get_global_mouse_position())
	rotation_degrees-= 90
	#rotation_degrees += rotation_speed * direction * delta
	if rotation_degrees >= max_rotation:
		rotation_degrees = max_rotation
	elif rotation_degrees <= min_rotation:
		rotation_degrees = min_rotation
		
