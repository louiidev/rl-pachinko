extends Node2D


@onready var cancel_btn: CustomBtn = $UI/CenterContainer2/HBoxContainer/Cancel
@onready var confirm_btn: CustomBtn = $UI/CenterContainer2/HBoxContainer/Confirm
@onready var money_label: Label = $UI/CenterContainer3/HBoxContainer/MoneyLabel
@onready var token_label: Label = $UI/CenterContainer4/HBoxContainer/TokenLabel


var cached_upgrades: Dictionary[Game.Upgrades, Dictionary]

func _ready() -> void:
	cancel_btn.button.pressed.connect(cancel_pressed)
	confirm_btn.button.pressed.connect(confirm)
	cached_upgrades = Game.upgrade_data.duplicate(true)

func cancel_pressed():
	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	Game.upgrade_data = cached_upgrades.duplicate(true)
	Game.cancel_prestige_scene()

func _process(_delta: float) -> void:
	money_label.text = "$"+str(Game.format_number_precise(Game.money))
	token_label.text = "Tokens: " + str(Game.tokens) + "/" + str(int(Game.get_upgrade_current_value(Game.Upgrades.MaxTokens)))
	
func confirm():	
	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	
	Game.confirm_prestige_scene()
