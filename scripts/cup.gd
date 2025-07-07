class_name Cup
extends Node2D

@onready var area: Area2D = $Area2D
@onready var label: Label = $Label


signal on_ball_collected(reward_amount: int, global_position: Vector2, ball_type: Ball.BallType)

var claimed_amount = 0

var prize = 0

func _ready() -> void:
	area.body_entered.connect(on_ball_entered)
	
func set_prize(prize_amount: int):
	prize = prize_amount
	claimed_amount = 0
	label.visible = true
	label.text = "$" + str(prize)


func on_ball_entered(body: Node2D):
	var max_claim_amount = 1 + Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimes)

	if claimed_amount < max_claim_amount:
		claimed_amount+= 1
		var ball: Ball = body
		on_ball_collected.emit(prize, global_position, ball.ball_type)
		if claimed_amount >= max_claim_amount:
			label.visible = false
	body.queue_free()
