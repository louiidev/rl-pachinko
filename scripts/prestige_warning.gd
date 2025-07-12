extends CenterContainer


@onready var cancel_btn: CustomBtn = $PanelContainer/VBoxContainer/HBoxContainer/Cancel
@onready var proceed_btn: CustomBtn = $PanelContainer/VBoxContainer/HBoxContainer/Proceed

func _ready() -> void:
	cancel_btn.button.pressed.connect(close_modal)
	proceed_btn.button.pressed.connect(go_to_prestige)

func go_to_prestige():
	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	Game.change_to_prestige_scene()	
	
func close_modal():
	hide()
