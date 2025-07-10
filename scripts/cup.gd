class_name Cup
extends Node2D

@onready var area: Area2D = $Area2D
@onready var label: Label = $Label
@onready var token: Sprite2D = $Token


signal on_ball_collected(reward_amount: int, global_position: Vector2, ball_type: Ball.BallType, ball_variant: Ball.BallVariant)
signal on_ball_collected_no_prize()
signal on_ball_collected_token()

var claimed_amount: int = 0
var prize: int = 0
var has_token = false
var max_claim_amount: int

func _ready() -> void:
	area.body_entered.connect(on_ball_entered)
	max_claim_amount = 1 + Game.get_upgrade_current_level(Game.Upgrades.PrizesCanBeClaimedXTimes)
	label.modulate = Color.WHITE
	label.text = "$0"

func set_prize(prize_amount: int = 0):
	claimed_amount = 0
	if prize_amount == 0:
		var max_level_reward = Game.get_current_level_base_reward() + ceili(Game.get_current_level_base_reward() * Game.get_upgrade_current_value(Game.Upgrades.MaxRewardAmountPercentage))
		prize = Game.rng.randi_range(1, max_level_reward)
		
	label.visible = true
	if prize_amount < 0:
		label.modulate = Color.RED
		label.text = "-$" + str(abs(prize))
	else:
		label.modulate = Color.WHITE
		label.text = "$" + str(prize)
		
	
func set_token():
	has_token = true
	token.show()
	label.visible = false
	prize = 0
	max_claim_amount = 1
	

func still_active() -> bool:
	return claimed_amount < max_claim_amount || has_token

func on_ball_entered(body: Node2D):
	if still_active():
		var ball: Ball = body
		claimed_amount += 1
		if has_token:
			has_token = false
			token.hide()
			on_ball_collected_token.emit(global_position)
		else:
			on_ball_collected.emit(prize, global_position, ball.ball_type, ball.ball_variant)
			
			if claimed_amount >= max_claim_amount:
				if Game.has_upgrade(Game.Upgrades.PrizesAlwaysRespawn):
					set_prize()
					
				else:
					label.visible = false
				
		
	else:
		claimed_amount += 1
		on_ball_collected_no_prize.emit()
	body.queue_free()
