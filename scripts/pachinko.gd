extends Node2D

@onready var cups_container: Node2D = $Board/Cups
@onready var ball_scene: PackedScene = preload("res://prefabs/Ball.tscn")


@onready var money_label: Label = $UI/PanelContainer/GameInfo/HBoxContainer/MoneyPanel/HBoxContainer/Panel3/Money
@onready var money_this_round_label: Label = $UI/PanelContainer/GameInfo/MoneyThisRoundPanel/HBoxContainer/Panel3/MoneyThisRound
@onready var time_left_label: Label = $UI/PanelContainer/GameInfo/TimeLeftPanel/TimeLeft
@onready var round_over_container = $RoundOverContainer
@onready var round_over_panel = $RoundOverContainer/Control/PanelContainer
@onready var round_over_text = $RoundOverContainer/Control/PanelContainer/VBoxContainer/Label2
@onready var upgrade_btn: CustomBtn = $RoundOverContainer/Control/PanelContainer/VBoxContainer/HBoxContainer/Upgrades
@onready var play_again_btn: CustomBtn = $RoundOverContainer/Control/PanelContainer/VBoxContainer/HBoxContainer/PlayAgain
@onready var options_btn: CustomBtn = $UI/PanelContainer/GameInfo/Options
@onready var game_info_container: Control = $UI/PanelContainer/GameInfo
@onready var level_label: Label = $UI/PanelContainer/GameInfo/HBoxContainer/LevelPanel/HBoxContainer/Panel3/LevelValue
@onready var multiplier_label: Label = $UI/PanelContainer/GameInfo/MoneyThisRoundPanel/HBoxContainer/Panel4/MoneyMultiplier
@onready var target_label: Label = $UI/PanelContainer/GameInfo/TargetPanel/Target

@onready var cannon_container = $Board/CannonContainer
@onready var cannon_prefab: PackedScene = preload("res://prefabs/Cannon.tscn")
@onready var money_prefab: PackedScene = preload("res://prefabs/MoneyDrop.tscn")


@onready var balls_container: Node2D = $BallsContainer

@onready var layout: Layout = $Board/Layout
@onready var money_container: Node2D = $MoneyContainer
@onready var board: Node2D = $Board
@onready var board_walls: Sprite2D = $Board/Walls

@onready var sfx_player: AudioLibrary = $SfxPlayer

var id_counter: int = 0
var multiplier: float = 1.0
var target: float = 0
var queue_restart: bool = false

func upgrade_btn_pressed() -> void:

	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	Game.change_to_upgrades_scene()

func replay_btn_pressed() -> void:
	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	Game.change_to_pachinko_scene()


func open_options():
	Input.action_press("settings")
	pass

func _ready() -> void:
	setup_level()
	Game.time_left = Game.get_start_level_time()
	Game.money_this_round = 0
	upgrade_btn.button.pressed.connect(upgrade_btn_pressed)
	play_again_btn.button.pressed.connect(replay_btn_pressed)
	options_btn.set_custom_width(game_info_container.size.x)
	options_btn.button.pressed.connect(open_options)
	money_this_round_label.text = "$0"
	level_label.text = str(Game.level)
	multiplier_label.text = str(multiplier)
	target = Game.calculate_target()
	target_label.text = "TARGET: $" + Game.format_number_precise(target)
	if Game.has_upgrade(Game.Upgrades.ExtraCannon):
		if Game.get_upgrade_current_value(Game.Upgrades.ExtraCannon) > 1:
			var cannon3: Cannon = cannon_prefab.instantiate()
			cannon_container.add_child(cannon3)
			cannon3.position.x+= 550

		var cannon2: Cannon = cannon_prefab.instantiate()
		cannon_container.add_child(cannon2)
		cannon2.position.x-= 550


func quick_reset_btn():
	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	Game.change_to_pachinko_scene()


func upgrades_scene_btn():
	Game.request_sfx(AudioLibrary.SoundFxs.Click)
	Game.change_to_upgrades_scene()




func ball_hit_peg(ball_global_pos: Vector2, volumn_db: float, peg_dead: bool):
	sfx_player.play_sfx(AudioLibrary.SoundFxs.PegHit, volumn_db)
	if Game.should_upgrade_be_triggered_chance(Game.Upgrades.ChanceToSplitBallOnPegHit):
		spawn_ball_peg(ball_global_pos)
	elif Game.should_upgrade_be_triggered_chance(Game.Upgrades.PegsHaveChanceToSpawnMiniBalls):
		spawn_ball_peg(ball_global_pos, Ball.BallVariant.Mini)

	if peg_dead:
		var money: Node2D = money_prefab.instantiate()
		money.global_position = ball_global_pos
		money_container.add_child.call_deferred(money)
		money.call_deferred("set_value", Game.level)

func spawn_peg_prize(prize: float, position: Vector2):
	var money: MoneyDrop = money_prefab.instantiate()
	money.global_position = position + Vector2(0, -40)
	money_container.add_child.call_deferred(money)
	money.call_deferred("set_value", prize)

func listen_to_pegs_hit():
	for peg: Peg in layout.get_children():
		peg.ball_hit_peg.connect(ball_hit_peg)
		peg.request_peg_prize.connect(spawn_peg_prize)


func set_target():
	var possible_prize_amount: int = 0

	for cup: Cup in cups_container.get_children():
		if cup.prize>0:
			possible_prize_amount+= cup.prize

	for peg: Peg in layout.get_children():
		if possible_prize_amount > 0:
			possible_prize_amount+= peg.prize



func setup_level():
	layout.call_deferred("setup_pegs")
	listen_to_pegs_hit.call_deferred()

	var possible_cup_indexes: Array[int] = []
	var max_level_reward = Game.get_current_level_base_reward() + ceili(Game.get_current_level_base_reward() * Game.get_upgrade_current_value(Game.Upgrades.MaxRewardAmountPercentage))
	for cup: Cup in cups_container.get_children():
		possible_cup_indexes.push_back(cup.get_index())
		cup.on_ball_collected.connect(cup_claimed_ball)
		cup.on_ball_collected_no_prize.connect(cup_claimed_ball_no_prize)
		cup.on_ball_collected_token.connect(on_ball_collected_token)
		cup.set_prize()

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

		possible_cup_indexes.remove_at(r_index)

	set_target.call_deferred()



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

func cup_claimed_ball(reward_amount: float, g_position: Vector2, ball_type: Ball.BallType, ball_variant_type: Ball.BallVariant):
	var upgrade_amount:= Ball.get_ball_upgrade_amount(ball_type, ball_variant_type, reward_amount)
	sfx_player.play_sfx(AudioLibrary.SoundFxs.PrizeClaimed)
	multiplier+= upgrade_amount
	multiplier_label.text = str(multiplier)

	if reward_amount >= 0:
		PopupManager.new_money_text(upgrade_amount, g_position)

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
		cannon.on_fire()
		sfx_player.play_sfx(AudioLibrary.SoundFxs.BallSpawned)
		var ball: RigidBody2D = ball_scene.instantiate()
		balls_container.call_deferred("add_child", ball)
		ball.call_deferred("spawn")
		var rotation_deg: float = cannon.rotation_degrees + Game.rng.randf_range(-2, 2)
		ball.apply_impulse(Vector2.from_angle(deg_to_rad(rotation_deg + 90)) * (750 + (abs(rotation_deg) * 0.5)))
		ball.global_position = cannon.cannon_spawn_point.global_position + Vector2(Game.rng.randf_range(-4, 4), 0)
		ball.id = id_counter
		id_counter+= 1


func reset_board():
	Game.money_this_round = 0

	money_this_round_label.text = "$0"
	for peg: Peg in layout.get_children():
		peg.ball_hit_peg.disconnect(ball_hit_peg)
	for cup: Cup in cups_container.get_children():
		cup.on_ball_collected.disconnect(cup_claimed_ball)
		cup.on_ball_collected_no_prize.disconnect(cup_claimed_ball_no_prize)
		cup.on_ball_collected_token.disconnect(on_ball_collected_token)
	#slayout._clear_existing_pegs()
	setup_level()


var autodrop_rate:= Game.get_cannon_firerate()

var has_fired_missed_target:= false
var has_started_time_left_timer: =false
func _process(_delta: float) -> void:
	if has_started_time_left_timer:
		Game.time_left-= Game.game_dt
	var formatted_time_left = max(Game.time_left, 0)
	var display_time_left_text: String = "%0.2f" % formatted_time_left
	time_left_label.text = "TIMELEFT: " + display_time_left_text + "s"

	money_label.text = "$" + Game.format_number_precise(Game.money)
	money_this_round_label.text = "$" + Game.format_number_precise(Game.money_this_round)
	autodrop_rate-= Game.game_dt
	if autodrop_rate <= 0.0:
		autodrop_rate = Game.get_cannon_firerate()
		spawn_ball()
		has_started_time_left_timer = true




	if Input.is_action_just_pressed("restart"):
		Game.change_to_pachinko_scene()

	if Game.time_left <= 0:
		if !has_fired_missed_target:
			has_fired_missed_target = true
			var score: float = multiplier * Game.money_this_round
			Game.end_of_round(multiplier)
			Game.save_game()
			var time_speed_tween = create_tween()
			time_speed_tween.tween_property(Game, "game_speed_modifier", 0.0, 1.3)
			time_speed_tween.set_ease(Tween.EASE_IN)
			await time_speed_tween.finished
			get_tree().paused = true
			if target > score:
				round_over_text.text = "Missed target of $"+Game.format_number_precise(target)+ "\nScore was: $"+ Game.format_number_precise(score)
			else:
				Game.level+= 1
				var bonus_type: = Game.get_level_bonus_type()
				if bonus_type == Game.LevelBonus.Token:
					round_over_text.text = "You scored $"+ Game.format_number_precise(score) + ", Bonus: 1 Token"
					Game.tokens+=1
				else:
					var bonus:= Game.calculate_bonus()
					round_over_text.text = "You scored $"+ Game.format_number_precise(score) + ", Bonus: $" + Game.format_number_precise(bonus)
					Game.money+= bonus
			var tween:= create_tween()
			round_over_panel.scale = Vector2.ZERO
			round_over_container.show()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(round_over_panel, "scale", Vector2(1, 1), 0.4)
			tween.set_ease(Tween.EaseType.EASE_OUT)
			tween.set_trans(Tween.TransitionType.TRANS_ELASTIC)
