@tool
class_name UpgradeNode extends Control

@export var next_nodes: Array[UpgradeNode]

@export var upgrade: Game.Upgrades


@onready var border: TextureRect = $Sprite/Border
@onready var color_rect: ColorRect = $Sprite/Border/ColorRect
@onready var button: TextureButton = $Button
@onready var popup: CenterContainer = $Popup

@onready var popup_name_label: Label = $Popup/PanelContainer/PopupInfo/Name
@onready var popup_description: Label = $Popup/PanelContainer/PopupInfo/MoneyPerSec
@onready var popup_level: Label = $Popup/PanelContainer/PopupInfo/Control/Level
@onready var popup_cost: Label = $Popup/PanelContainer/PopupInfo/Control2/Cost

@onready var shaker: Motion = $Shaker
@onready var shaker2: Motion = $Shaker2
@onready var shaker3: Motion = $Shaker3
@onready var shaker4: Motion = $Shaker4
@onready var scene_parent: Node2D

@onready var sprite = $Sprite

@onready var timer: Timer = $ClosePopupTimer
@onready var debounce_timer: Timer = $DebounceTimer

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
		popup_cost.text = "$" + str(Game.get_upgrade_current_cost(upgrade))

func close_popup_timer():
	popup.hide()
	
	
func set_up_lines():
	for node: UpgradeNode in next_nodes:
		var line = Line2D.new()
		
		line.z_index = -2
		line.width = 2.0
		line.add_point(scene_parent.to_local(border.global_position + border.size * 0.5))
		line.add_point(scene_parent.to_local(node.border.global_position + border.size * 0.5))
		scene_parent.add_child.call_deferred(line)

func _ready() -> void:
	if texture != null:
		sprite.texture = texture
	if Engine.is_editor_hint():
		return
	button.pressed.connect(on_upgrade)
	popup.hide()
	button.mouse_entered.connect(hover)
	set_popup_data_ui()
	scene_parent = get_parent().get_parent()
	timer.timeout.connect(close_popup_timer)
	
	
	color_rect.color = RenderingServer.get_default_clear_color()
	set_up_lines.call_deferred()

	
	

func on_upgrade():
	shaker.add_motion(1.1)
	shaker3.add_motion(1.1)
	shaker4.add_motion(1.1)
	Game.on_upgrade_level_up(upgrade)
	set_popup_data_ui()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if !visible:
		return
		
		
	if !button.is_hovered() && popup.visible && timer.is_stopped():
		var rect = Rect2(global_position - abs(pivot_offset), size + abs(pivot_offset))
		if !rect.has_point(get_global_mouse_position()):
			timer.start(0.15)
			print("TIMER START")
			
		
	button.disabled = Game.get_upgrade_current_cost(upgrade) > Game.money || Game.get_upgrade_current_level(upgrade) >= Game.get_upgrade_max_level(upgrade)
	
	if button.disabled:
		border.modulate = Color.GREEN if Game.get_upgrade_current_level(upgrade) >= Game.get_upgrade_max_level(upgrade) else Color.RED 
	else:
		border.modulate = Color.WHITE
