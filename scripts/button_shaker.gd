extends Button



@onready var shaker: Motion = $Shaker


func hover():
	if !disabled:
		shaker.add_motion()

func dehover():
	if !disabled:
		shaker.add_motion(1.05)
	



func _ready() -> void:
	mouse_entered.connect(hover)
	mouse_exited.connect(dehover)
