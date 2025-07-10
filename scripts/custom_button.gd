@tool
class_name CustomBtn extends Control


@onready var button: Button = $Button
@onready var label_node: Label = $Button/Label


enum Variant {
	Primary,
	Secondary
}

@export var label: String = "Label"
@export var variant: Variant = Variant.Primary


func setup():
	label_node.text = label
	button.text = label
	
	if (variant == Variant.Secondary):
		button.remove_theme_stylebox_override("normal")
		button.remove_theme_stylebox_override("hover")
		button.remove_theme_stylebox_override("focus")
		#button.add_theme_stylebox_override("")
		#button.add_theme_stylebox_override("")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		setup()
func _ready() -> void:
	setup()
	
