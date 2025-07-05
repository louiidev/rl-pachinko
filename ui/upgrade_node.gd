@tool
class_name UpgradeNode extends TextureButton

@export var next_nodes: Array[UpgradeNode]

@export var upgrade: Game.Upgrades


@onready var border: TextureRect = $Border
@onready var popup: CenterContainer = $Popup

@onready var popup_name_label: Label = $Popup/PanelContainer/PopupInfo/Name
@onready var popup_description: Label = $Popup/PanelContainer/PopupInfo/MoneyPerSec
@onready var popup_level: Label = $Popup/PanelContainer/PopupInfo/Level
@onready var popup_cost: Label = $Popup/PanelContainer/PopupInfo/Cost


@onready var scene_parent: Node2D


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

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	pressed.connect(on_upgrade)
	popup.hide()
	
	set_popup_data_ui()
	scene_parent = get_parent().get_parent()
	
	for node: UpgradeNode in next_nodes:
		var line = Line2D.new()
		line.width = 2.0
		line.add_point(scene_parent.to_local(global_position + size * 0.5))
		line.add_point(scene_parent.to_local(node.global_position + size * 0.5))
		scene_parent.add_child.call_deferred(line)
	
	

func on_upgrade():
	Game.on_upgrade_level_up(upgrade)
	set_popup_data_ui()

func _process(delta: float) -> void:
	if !visible || Engine.is_editor_hint():
		return
		
	var global_rect:= Rect2(global_position, size)
	
	if global_rect.has_point(get_global_mouse_position()):
		popup.show()
	else:
		popup.hide()
		
	disabled = Game.get_upgrade_current_cost(upgrade) > Game.money || Game.get_upgrade_current_level(upgrade) >= Game.get_upgrade_max_level(upgrade)
	
	if disabled:
		border.modulate = Color.GREEN if Game.get_upgrade_current_level(upgrade) >= Game.get_upgrade_max_level(upgrade) else Color.RED 
	else:
		border.modulate = Color.WHITE
