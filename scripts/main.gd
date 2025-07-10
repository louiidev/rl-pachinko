extends Node2D

@onready var cups_container: Node2D = $Board/Cups
@onready var ball_scene: PackedScene = preload("res://prefabs/Ball.tscn")


@onready var upgrades_btn: CustomBtn = $UI/GameInfo/UpgradesBtn
@onready var quick_restart_btn: CustomBtn = $UI/GameInfo/QuickRestartBtn
@onready var money_label: Label = $UI/GameInfo/Money
@onready var highscore_label: Label = $UI/GameInfo/Highscore


@onready var cannon_container = $Board/CannonContainer
@onready var cannon_prefab: PackedScene = preload("res://prefabs/Cannon.tscn")


@onready var balls_container: Node2D = $BallsContainer

@onready var layout: Layout = $Board/Layout
@onready var board: Node2D = $Board
@onready var board_walls: Sprite2D = $Board/Walls

@onready var sfx_player: AudioLibrary = $SfxPlayer

var id_counter: int = 0


var queue_restart: bool = false


func _ready() -> void:
	setup_level()
	highscore_label.text = "Highscore: $" + Game.format_number_precise(Game.highscore)
	upgrades_btn.button.pressed.connect(upgrades_scene_btn)
	quick_restart_btn.button.pressed.connect(quick_reset_btn)
	if Game.has_upgrade(Game.Upgrades.ExtraCannon):
		if Game.get_upgrade_current_value(Game.Upgrades.ExtraCannon) > 1:
			var cannon: Cannon = cannon_prefab.instantiate()
			cannon_container.add_child(cannon)
			cannon.position.x+= 550
		
		var cannon: Cannon = cannon_prefab.instantiate()
		cannon_container.add_child(cannon)
		cannon.position.x-= 550


func quick_reset_btn():
	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	Game.change_to_pachinko_scene()
	
	
func upgrades_scene_btn():
	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	Game.change_to_upgrades_scene()
	
	


func ball_hit_peg(ball_global_pos: Vector2, volumn_db: float):
	sfx_player.play_sfx(AudioLibrary.SoundFxs.PegHit, volumn_db)
	if Game.should_upgrade_be_triggered_chance(Game.Upgrades.ChanceToSplitBallOnPegHit):
		spawn_ball_peg(ball_global_pos)
	elif Game.should_upgrade_be_triggered_chance(Game.Upgrades.PegsHaveChanceToSpawnMiniBalls):
		spawn_ball_peg(ball_global_pos, Ball.BallVariant.Mini)
	
	

func listen_to_pegs_hit():
	for peg: Peg in layout.get_children():
		peg.ball_hit_peg.connect(ball_hit_peg)

func setup_level():
	layout.call_deferred("setup_pegs")
	listen_to_pegs_hit.call_deferred()
	
	
	var timer:= get_tree().create_timer(0.5)
	
	var possible_cup_indexes: Array[int] = []
	var max_level_reward = Game.get_current_level_base_reward() + ceili(Game.get_current_level_base_reward() * Game.get_upgrade_current_value(Game.Upgrades.MaxRewardAmountPercentage))

	for cup: Cup in cups_container.get_children():
		possible_cup_indexes.push_back(cup.get_index())
		cup.on_ball_collected.connect(cup_claimed_ball)
		cup.on_ball_collected_no_prize.connect(cup_claimed_ball_no_prize)
		cup.on_ball_collected_token.connect(on_ball_collected_token)
		if Game.should_negative_upgrade_be_triggered_chance(Game.Upgrades.LessNegativePrizes):
			var value:= Game.rng.randi_range(min(-max_level_reward, -2), -1)
			cup.set_prize(value)
		
		
	var prize_cup_amount:= Game.rng.randi_range(Game.get_upgrade_current_value(Game.Upgrades.MinRewardColumns), possible_cup_indexes.size() - 1)
	for prize_count in prize_cup_amount:
		if possible_cup_indexes.size() == 0:
			break
		
		var r_index:= Game.rng.randi_range(0, possible_cup_indexes.size() - 1)
#		so to prevent us assigning prizes to multiple cups at once, we are popping this array once we assing a prize
		var cup_index:=possible_cup_indexes[r_index]
		var cup: Cup = cups_container.get_child(cup_index)
		if Game.tokens < Game.get_upgrade_current_value(Game.Upgrades.MaxTokens) && Game.should_upgrade_be_triggered_chance(Game.Upgrades.TokensCanSpawnPercentage):
			cup.set_token()
		else:
			cup.set_prize()
		possible_cup_indexes.remove_at(r_index)


func cup_claimed_ball_no_prize():
	if Game.should_upgrade_be_triggered_chance(Game.Upgrades.ChanceBallRespawnsOnMissedPrize) && balls_container.get_child_count() < 50:				
		if has_prizes_left():
			spawn_ball()
			
			
func has_prizes_left() -> bool:
	var has_prizes_left: bool = false
	for cup: Cup in cups_container.get_children():
		if cup.still_active() && cup.prize > 0:
			print("cup ", cup.prize, " ", cup.claimed_amount, " ", cup.max_claim_amount)
			has_prizes_left = true
			break
	
	if !has_prizes_left:
		for peg: Peg in layout.get_children():
			if peg.is_prize_active():
				has_prizes_left = true
				print("peg ", peg.prize, " ", peg.claimed_amount)
				break
				
	return has_prizes_left
			

func on_ball_collected_token(g_position: Vector2):
	if Game.get_upgrade_current_value(Game.Upgrades.MaxTokens) > Game.tokens:
		Game.tokens+= 1
		PopupManager.new_token_text(g_position)

func cup_claimed_ball(reward_amount: int, g_position: Vector2, ball_type: Ball.BallType, ball_variant_type: Ball.BallVariant):
	var upgrade_amount:= Ball.get_ball_upgrade_amount(ball_type, ball_variant_type, reward_amount)
	sfx_player.play_sfx(AudioLibrary.SoundFxs.PrizeClaimed)
	
	
	Game.add_money(upgrade_amount)
	
	
	if reward_amount >= 0:
		PopupManager.new_money_text(upgrade_amount, g_position)
	else:
		PopupManager.negative_money_text(upgrade_amount, g_position)
	if reward_amount == 0:
		cup_claimed_ball_no_prize()
	elif Game.should_upgrade_be_triggered_chance(Game.Upgrades.ChanceToSpawnBallOnPrizeClaim) && balls_container.get_child_count() < 50:
		spawn_ball()
		

func spawn_ball_peg(pos: Vector2, variant: Ball.BallVariant = Ball.BallVariant.Normal):
	if balls_container.get_child_count() > 250:
		return
	sfx_player.play_sfx(AudioLibrary.SoundFxs.BallSpawned)
	var ball: Ball = ball_scene.instantiate()
	
	balls_container.call_deferred("add_child", ball)
	ball.call_deferred("spawn", variant)
	ball.global_position = pos
	ball.id = id_counter
	id_counter+= 1
	ParticleManager.spawn_smoke_particle(ball.global_position)

func spawn_ball():
	for cannon: Cannon in cannon_container.get_children():
		if balls_container.get_child_count() > 250:
			return
		
		sfx_player.play_sfx(AudioLibrary.SoundFxs.BallSpawned)
		var ball: RigidBody2D = ball_scene.instantiate()
		balls_container.call_deferred("add_child", ball)
		ball.call_deferred("spawn")
		var rotation_deg: float = cannon.rotation_degrees
		ball.apply_impulse(Vector2.from_angle(deg_to_rad(rotation_deg + 90)) * (750 + (abs(rotation_deg) * 0.5)))
		ball.global_position = cannon.cannon_spawn_point.global_position
		ball.id = id_counter
		id_counter+= 1
	


var autodrop_rate:= Game.get_upgrade_current_value(Game.Upgrades.AutoDropperRate)

var was_paused = false
func _process(_delta: float) -> void:	
	money_label.text = "Money: $" + Game.format_number_precise(Game.money)
	autodrop_rate-= _delta
	if autodrop_rate <= 0.0:
		autodrop_rate = Game.get_upgrade_current_value(Game.Upgrades.AutoDropperRate)
		if Game.has_upgrade(Game.Upgrades.AutoDropper):
			spawn_ball()
	
	if Input.is_action_just_pressed("left_click"):
		var rect:= board_walls.get_rect()
		var global_rect = Rect2(board_walls.global_position - rect.size * 0.5 - Vector2(0, 200), rect.size + Vector2(0, 200))
		if global_rect.has_point(get_global_mouse_position()):
			spawn_ball()
				
	if Input.is_action_just_pressed("space"):
		
		spawn_ball()
	
		
	if Input.is_action_just_pressed("restart"):
		Game.change_to_pachinko_scene()
