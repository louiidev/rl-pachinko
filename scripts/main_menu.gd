extends Node2D


@onready var ball_scene: PackedScene = preload("res://prefabs/MenuBall.tscn")
@onready var timer: Timer = $Timer
@onready var spawn_point: Marker2D = $SpawnPoint

@onready var start_btn: CustomBtn = $Menu/VBoxContainer/StartBtn
@onready var load_btn: CustomBtn = $Menu/VBoxContainer/LoadBtn
@onready var option_btn: CustomBtn = $Menu/VBoxContainer/OptionsBtn

func _ready() -> void:
	

	timer.timeout.connect(spawn_ball)
	start_btn.button.pressed.connect(Game.change_to_pachinko_scene)
	option_btn.button.pressed.connect(show_options)
	load_btn.button.disabled = !Game.has_save()
	load_btn.button.pressed.connect(load_game)

func load_game():
	Game.load_save()
	Game.change_to_upgrades_scene()

func show_options():
	Input.action_press("settings")

func spawn_ball():
	var ball: Ball = ball_scene.instantiate()
	spawn_point.add_child.call_deferred(ball)
	ball.call_deferred("spawn_menu_ball")
	if spawn_point.get_child_count() > 300:
		timer.paused = true
