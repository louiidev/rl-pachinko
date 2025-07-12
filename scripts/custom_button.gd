@tool
class_name CustomBtn extends Control


@onready var button: Button = $Button
@onready var label_node: Label = $Button/Label



enum Variant {
	Primary,
	Secondary
}

enum SizeVariant {
	Standard,
	Small
}


@export var label: String = "Label"
@export var variant: Variant = Variant.Primary
@export var size_variant: SizeVariant = SizeVariant.Standard


func set_custom_width(width: float):
	button.custom_minimum_size.x = width
	self.size.x = width
	button.pivot_offset.x = width *0.5

func setup():
	if label_node == null:
		return
		
	label_node.text = label
	button.text = label
	
	if (size_variant == SizeVariant.Small):
		button.size.x = 350
		button.custom_minimum_size.x = 432.0
	else:
		button.custom_minimum_size.x = 500.0
	
	button.custom_minimum_size.y = 156.0
	
	size.x = button.size.x
	button.pivot_offset = button.size * 0.5
	
	if (variant == Variant.Secondary):
		button.remove_theme_stylebox_override("normal")
		button.remove_theme_stylebox_override("hover")
		button.remove_theme_stylebox_override("focus")
		#button.add_theme_stylebox_override("")
		#button.add_theme_stylebox_override("")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		setup()
func _ready() -> void:
	setup()
	
