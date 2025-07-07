extends Node2D

@onready var cups_container: Node2D = $Board/Cups
@onready var ball_scene: PackedScene = preload("res://Ball.tscn")


@onready var quick_restart_btn: Button = $UI/GameInfo/QuickRestartButtonContainer/QuickRestartButton
@onready var upgrades_btn: Button = $UI/GameInfo/UpgradeBtnContainer/UpgradesButton
@onready var money_label: Label = $UI/GameInfo/Money
@onready var balls_label: Label = $UI/GameInfo/Balls

@onready var cannon: Cannon = $Board/Cannon
@onready var cannon_spawn_point: Marker2D = $Board/Cannon/SpawnPoint

@onready var balls_container: Node2D = $BallsContainer

@onready var layout: Layout = $Board/Layout
@onready var board_walls: Sprite2D = $Board/Walls

var id_counter: int = 0

var balls_left: int = 0

var queue_restart: bool = false

func _ready() -> void:
	setup_level()
	quick_restart_btn.pressed.connect(Game.change_to_pachinko_scene)
	upgrades_btn.pressed.connect(Game.change_to_upgrades_scene)


func check_level_completed():
	if balls_left == 0 && balls_container.get_child_count() == 0:
		quick_restart_btn.show()
		if queue_restart:
			Game.change_to_pachinko_scene()
	else:
		var timer:= get_tree().create_timer(0.15)
		timer.timeout.connect(check_level_completed)


func ball_hit_peg(ball_global_pos: Vector2):
	if Game.should_upgrade_be_triggered_chance(Game.Upgrades.ChanceToSplitBallOnPegHit):
		spawn_ball_peg(ball_global_pos)

#func restart_level():
	#for cup: Cup in cups_container.get_children():
		#cup.on_ball_collected.disconnect(cup_claimed_ball)
		#
	#for peg: Peg in layout.get_children():
		#peg.ball_hit_peg.disconnect(ball_hit_peg)
	#setup_level()

func listen_to_pegs_hit():
	for peg: Peg in layout.get_children():
		peg.ball_hit_peg.connect(ball_hit_peg)

func setup_level():
	Game.money_this_game = 0
	layout.call_deferred("setup_pegs")
	listen_to_pegs_hit.call_deferred()
	quick_restart_btn.hide()
	balls_left = Game.get_upgrade_current_value(Game.Upgrades.MaxBalls)
	balls_label.text = "Balls left: " + str(balls_left)
	
	
	var timer:= get_tree().create_timer(0.5)
	timer.timeout.connect(check_level_completed)
	
	var possible_cup_indexes: Array[int] = []
	
	for cup: Cup in cups_container.get_children():
		cup.set_prize(0)
		possible_cup_indexes.push_back(cup.get_index())
		cup.on_ball_collected.connect(cup_claimed_ball)
	
	
		
	var prize_cup_amount:= Game.rng.randi_range(Game.get_upgrade_current_value(Game.Upgrades.MinRewardColumns), possible_cup_indexes.size() - 1)
	for prize_count in prize_cup_amount:
		if possible_cup_indexes.size() == 0:
			break
		var r_index:= Game.rng.randi_range(0, possible_cup_indexes.size() - 1)
#		so to prevent us assigning prizes to multiple cups at once, we are popping this array once we assing a prize
		var cup_index:=possible_cup_indexes[r_index]
		var cup: Cup = cups_container.get_child(cup_index)
		var max_level_reward = Game.get_current_level_base_reward() + ceili(Game.get_current_level_base_reward() * Game.get_upgrade_current_value(Game.Upgrades.MaxRewardAmountPercentage))
		cup.set_prize(Game.rng.randi_range(1, max_level_reward))
		possible_cup_indexes.remove_at(r_index)


func cup_claimed_ball(reward_amount: int, g_position: Vector2, ball_type: Ball.BallType):
	var upgrade_amount:= 0
	match ball_type:
		Ball.BallType.Bronze:
			upgrade_amount+= reward_amount * 5
		Ball.BallType.Silver:
			upgrade_amount+= reward_amount * 10
		Ball.BallType.Gold:
			upgrade_amount+= reward_amount * 25
		Ball.BallType.Diamond:
			upgrade_amount+= reward_amount * 50
		Ball.BallType.Platinum:
			upgrade_amount+= reward_amount * 100
	
	
	Game.money_this_game+= reward_amount + upgrade_amount
	Game.money+= reward_amount + upgrade_amount
	money_label.text = "$" + str(Game.money)
	PopupManager.new_money_text(reward_amount + upgrade_amount, g_position)
	if Game.should_upgrade_be_triggered_chance(Game.Upgrades.ChanceToSpawnBallOnPrizeClaim):
		spawn_ball()

func spawn_ball_peg(pos: Vector2):
	var ball: RigidBody2D = ball_scene.instantiate()
	balls_container.call_deferred("add_child", ball)
	ball.call_deferred("spawn")
	ball.global_position = pos
	ball.id = id_counter
	id_counter+= 1

func spawn_ball():
	
	var ball: RigidBody2D = ball_scene.instantiate()
	balls_container.call_deferred("add_child", ball)
	ball.call_deferred("spawn")
	var rotation_deg: float = cannon.rotation_degrees
	ball.apply_impulse(Vector2.from_angle(deg_to_rad(rotation_deg + 90)) * (750 + (abs(rotation_deg) * 0.5)))
	ball.global_position = cannon_spawn_point.global_position
	ball.id = id_counter
	id_counter+= 1
	


func _process(_delta: float) -> void:
	money_label.text = "Money this round: $" + Game.format_number_precise(Game.money_this_game)
	if balls_left > 0:
		if Input.is_action_just_pressed("left_click"):
			var rect:= board_walls.get_rect()
			var global_rect = Rect2(board_walls.global_position - rect.size * 0.5 - Vector2(0, 200), rect.size + Vector2(0, 200))
			if global_rect.has_point(get_global_mouse_position()):
				balls_left-=1
				balls_label.text = "Balls left: " + str(balls_left)
				spawn_ball()
				
		if Input.is_action_just_pressed("space"):
			balls_left-=1
			balls_label.text = "Balls left: " + str(balls_left)
			spawn_ball()
	
		
	if Input.is_action_just_pressed("restart"):
		print("RESTART")
		if balls_left == 0 && balls_container.get_child_count() == 0:
			Game.change_to_pachinko_scene()
		else:
			queue_restart = true
