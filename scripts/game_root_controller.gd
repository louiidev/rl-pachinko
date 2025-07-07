class_name GameRoot extends Node2D


@export var start_scene: Scene = Scene.GameBoard

@onready var current_scene: Node2D = $CurrentScene
@onready var transition: Transition = $Transition

enum Scene {
	GameBoard,
	Upgrades,
}
@onready var scenes: Dictionary[Scene, PackedScene] = {
	Scene.GameBoard: preload("res://scenes/Main.tscn"),
	Scene.Upgrades: preload("res://scenes/Upgrades.tscn")
}

@onready var scene_names: Dictionary[Scene, String] = {
	Scene.GameBoard: "PACHINKO!",
	Scene.Upgrades: "UPGRADES",
}

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.html("#222034"))
	current_scene.add_child(scenes[start_scene].instantiate())
	Game.change_scene_request.connect(chance_scene_request)
	

func hide_transition():
	transition.end_transition()
	
	

func chance_scene_request(scene: Scene):
	await transition.start_transition(Color.html("#433d76"), scene_names[scene])
	for child in current_scene.get_children():
		child.queue_free()
	
	var child: Node2D = scenes[scene].instantiate()
	current_scene.add_child(child)
	
	if !child.is_node_ready():
		await child.ready
		hide_transition()
	else:
		hide_transition()
	
	
