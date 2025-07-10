
extends Node2D


var text_scene : PackedScene = preload("res://prefabs/PopupText.tscn")
var child_container: Node2D



func clear_particles(_scene):
	for child: PopupText in child_container.get_children():
		child.change_scene()
		

func _ready() -> void:
	child_container = Node2D.new()
	var scene:= get_tree().root
	scene.call_deferred("add_child", child_container)
	Game.change_scene_request.connect(clear_particles)

func new_text(txt: String, g_position: Vector2, color: Color):
	var label_parent: Node2D = text_scene.instantiate()
	var label: Label = label_parent.get_node("PopupText")
	label.text = txt

	child_container.add_child(label_parent)
	label_parent.global_position = g_position
	label.modulate = color
	label.pivot_offset = label.size / 2

func new_money_text(amount: int, g_position: Vector2):
	new_text("$" +Game.format_number_precise(amount), g_position, Color.WEB_GREEN)

func negative_money_text(amount: int, g_position: Vector2):
	new_text("-$" + Game.format_number_precise(abs(amount)), g_position, Color.RED)


func new_token_text(g_position: Vector2):
	new_text("+1 Token", g_position, Color.CRIMSON)
