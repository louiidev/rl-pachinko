@tool
class_name UpgradeNode extends Node2D

@export var upgrade: Game.Upgrades

@onready var border: TextureRect = $Sprite/Border
@onready var color_rect: ColorRect = $Sprite/Border/ColorRect
@onready var button: TextureButton = $Button
@onready var popup: CenterContainer = $Popup
@onready var popup_panel: PanelContainer = $Popup/PanelContainer

@onready var popup_name_label: Label = $Popup/PanelContainer/PopupInfo/Name
@onready var popup_description: Label = $Popup/PanelContainer/PopupInfo/MoneyPerSec
@onready var popup_level: Label = $Popup/PanelContainer/PopupInfo/Control/Level
@onready var popup_cost: Label = $Popup/PanelContainer/PopupInfo/Control2/Cost

@onready var shaker: Motion = $Shaker
@onready var shaker2: Motion = $Shaker2
@onready var shaker3: Motion = $Shaker3
@onready var shaker4: Motion = $Shaker4

@onready var sprite: TextureRect = $Sprite
@onready var tick: Sprite2D = $Tick

@onready var timer: Timer = $ClosePopupTimer
@onready var debounce_timer: Timer = $DebounceTimer
@onready var sfx_player: AudioLibrary = $SfxPlayer

@export var texture: Texture2D

func hover():
	if debounce_timer.is_stopped():
		shaker.add_motion()
		shaker2.add_motion(0.4)
		debounce_timer.start(0.4)
	popup.show()
	timer.stop()
	

func set_popup_data_ui():
	var current_level = Game.get_upgrade_current_level(upgrade)
	var max_level = Game.get_upgrade_max_level(upgrade)
	popup_name_label.text = Game.get_upgrade_name(upgrade)
	popup_description.text = Game.get_upgrade_description(upgrade)
	popup_level.text = "Lvl " + str(current_level) + "/" + str(max_level)
	if current_level == max_level:
		popup_cost.hide()
	else:
		popup_cost.text = "$" + str(Game.get_upgrade_next_cost(upgrade))

func close_popup_timer():
	popup.hide()
	
	
func show_next_nodes(build_lines_always: bool = false):
	for child in get_children():
		if !is_upgrade_node_instance(child):
			continue
		var node: UpgradeNode = child
		if Game.is_upgrade_money_per_second(upgrade) && Game.is_upgrade_money_per_second(node.upgrade) && Game.get_upgrade_current_level(upgrade) < Game.get_upgrade_max_level(upgrade):
			node.hide()
			continue
		if !child.visible || build_lines_always:
			child.show()
			var line = Line2D.new()
			line.z_index = -2
			line.width = 2.0
			line.add_point(Vector2.ZERO)
			line.add_point(child.position)
			self.add_child.call_deferred(line)
		
			

func is_upgrade_node_instance(node: Node) -> bool:
	return node.get_script() != null && node.get_script().get_global_name() == "UpgradeNode"

		
func hide_children_recursively():
	for child in get_children():
		if !is_upgrade_node_instance(child):
			continue
		var node: UpgradeNode = child
		
		node.hide()
		

var panel_y_pos: float
func _ready() -> void:
	if texture != null:
		sprite.texture = texture
	if Engine.is_editor_hint():
		return
	button.pressed.connect(on_upgrade)
	popup.hide()
	button.mouse_entered.connect(hover)
	set_popup_data_ui()
	timer.timeout.connect(close_popup_timer)
	
	color_rect.color = RenderingServer.get_default_clear_color()
	

	if Game.get_upgrade_current_level(upgrade) == Game.get_upgrade_max_level(upgrade):
		tick.show()
	
	
	panel_y_pos = popup.global_position.y
	if panel_y_pos < 10:
		popup.position.y = 80
	if Game.get_upgrade_current_level(upgrade) > 0:
		show_next_nodes.call_deferred(true)
	else:
		hide_children_recursively()
		

func should_show_children_nodes() -> bool:
	if upgrade == Game.Upgrades.Customers && Game.get_upgrade_current_level(upgrade) == 1:
		return true
	return Game.is_upgrade_money_per_second(upgrade) && Game.get_upgrade_current_level(upgrade) == Game.get_upgrade_max_level(upgrade)  || !Game.is_upgrade_money_per_second(upgrade) && Game.get_upgrade_current_level(upgrade) > 0
	

func on_upgrade():
	shaker.add_motion(1.1)
	shaker3.add_motion(1.1)
	shaker4.add_motion(1.1)
	Game.on_upgrade_level_up(upgrade)
	set_popup_data_ui()

	sfx_player.play_sfx(AudioLibrary.SoundFxs.Click)
	
	show_next_nodes.call_deferred()

	if Game.get_upgrade_current_level(upgrade) == Game.get_upgrade_max_level(upgrade):
		tick.show()
		


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if !visible:
		return
		
		
	if !button.is_hovered() && popup.visible && timer.is_stopped():
		var rect = Rect2(border.global_position, border.size)
		if !rect.has_point(get_global_mouse_position()):
			timer.start(0.15)
			
			
			
	var money_type : int = Game.tokens if Game.is_upgrade_prestige_upgrade(upgrade) else Game.money
		
	button.disabled = Game.get_upgrade_next_cost(upgrade) > money_type || Game.get_upgrade_current_level(upgrade) >= Game.get_upgrade_max_level(upgrade)
	
	if button.disabled:
		border.modulate = Color.GREEN if Game.get_upgrade_current_level(upgrade) >= Game.get_upgrade_max_level(upgrade) else Color.DARK_RED 
	else:
		border.modulate = Color.WHITE
		if Game.get_upgrade_current_level(upgrade) == 0:
			border.modulate.a = 0.3
