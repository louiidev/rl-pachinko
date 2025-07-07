extends Button



@onready var shaker: Motion = $Shaker


func hover():
	shaker.add_motion()

func dehover():
	shaker.add_motion(1.05)
	



func _ready() -> void:
	mouse_entered.connect(hover)
	mouse_exited.connect(dehover)
