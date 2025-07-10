class_name GameRoot extends Node2D


@export var start_scene: Scene = Scene.GameBoard


@onready var current_scene: Node2D = $CurrentScene
@onready var transition: Transition = $Transition
@onready var settings_menu: Control = $Settings
@onready var settings_exit: CustomBtn = $Settings/PanelContainer/VBoxContainer/CustomBtn
var current_scene_key: Scene

enum Scene {
	GameBoard,
	Upgrades,
	Prestige,
	MainMenu,
	LoadingIntro
}

@onready var scenes: Dictionary[Scene, PackedScene] = {
	Scene.GameBoard: preload("res://scenes/Main.tscn"),
	Scene.Upgrades: preload("res://scenes/Upgrades.tscn"),
	Scene.Prestige: preload("res://scenes/Prestige.tscn"),
	Scene.MainMenu: preload("res://scenes/MainMenu.tscn"),
	Scene.LoadingIntro: preload("res://scenes/MainMenu.tscn"),
}

var transition_speed: Dictionary[Scene, float] = {
	Scene.GameBoard: 0.15,
	Scene.Upgrades: 0.15,
	Scene.Prestige: 0.8,
	Scene.MainMenu: 0.8,
}

@onready var scene_names: Dictionary[Scene, String] = {
	Scene.GameBoard: "PACHINKO!",
	Scene.Upgrades: "UPGRADES",
	Scene.Prestige: "PRESTIGE",
}

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.html("#222034"))
	current_scene.add_child(scenes[start_scene].instantiate())
	settings_menu.hide()
	settings_exit.button.pressed.connect(hide_settings)
	Game.change_scene_request.connect(chance_scene_request)
	current_scene_key = start_scene
func hide_transition():
	transition.end_transition()


	

func hide_settings():
	settings_menu.hide()
	get_tree().paused = false
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("settings"):
		settings_menu.visible = !settings_menu.visible
		get_tree().paused = settings_menu.visible


func chance_scene_request(scene: Scene):
	await transition.start_transition(Color.html("#433d76"), scene_names[scene], transition_speed[current_scene_key])
	current_scene_key = scene
	for child in current_scene.get_children():
		child.queue_free()
	
	var child: Node2D = scenes[scene].instantiate()
	current_scene.add_child(child)
	
	if !child.is_node_ready():
		await child.ready
		hide_transition()
	else:
		hide_transition()
	
	
