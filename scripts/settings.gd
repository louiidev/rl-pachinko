extends CenterContainer



@onready var disabled_transition_animations_ui: CheckButton = $PanelContainer/VBoxContainer/DisableTransAnimations
@onready var check_ui_speed: SpinBox = $PanelContainer/VBoxContainer/ChangeUIAnimationSpeed


func _ready() -> void:
	disabled_transition_animations_ui.pressed.connect(on_disabled_pressed)
		
	
func on_disabled_pressed():
	Game.disabled_transition = disabled_transition_animations_ui.button_pressed
