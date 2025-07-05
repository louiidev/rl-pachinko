extends Node2D



@onready var play_pachinko_btn: Button = $UI/CenterContainer2/Button
@onready var money_label: Label = $UI/CenterContainer3/HBoxContainer/MoneyLabel
@onready var money_per_second_label: Label = $UI/CenterContainer3/HBoxContainer/MoneyPerSecond


func _ready() -> void:
	play_pachinko_btn.pressed.connect(play_pachinko)
	
	
func _process(delta: float) -> void:
	money_label.text = "$"+str(Game.format_number_precise(Game.money))
	money_per_second_label.text = "[$"+str(Game.format_number_precise(Game.calculate_per_second_money()))+ " / secs]"
	

	
func play_pachinko():
	Game.change_to_pachinko_scene()
