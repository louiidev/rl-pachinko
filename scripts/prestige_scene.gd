extends Node2D


@onready var play_pachinko_btn: Button = $UI/CenterContainer2/Control/Button
@onready var money_label: Label = $UI/CenterContainer3/HBoxContainer/MoneyLabel
@onready var token_label: Label = $UI/CenterContainer4/HBoxContainer/TokenLabel
@onready var money_per_second_label: Label = $UI/CenterContainer3/HBoxContainer/MoneyPerSecond


func _ready() -> void:
	play_pachinko_btn.pressed.connect(play_pachinko)

func _process(_delta: float) -> void:
	money_label.text = "$"+str(Game.format_number_precise(Game.money))
	money_per_second_label.text = "[$"+str(Game.format_number_precise(Game.calculate_per_second_money()))+ " / secs]"
	token_label.text = "Tokens: " + str(Game.tokens) + "/" + str(int(Game.get_upgrade_current_value(Game.Upgrades.MaxTokens)))
	
	
func play_pachinko():	
	Game.tokens = 0
	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	Game.change_to_pachinko_scene()
