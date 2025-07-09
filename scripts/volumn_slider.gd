extends HSlider


@export var bus_name: String

var bus_index: int = -1

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(on_value_changed)
	
func on_value_changed(value: float):
	AudioServer.set_bus_volume_linear(bus_index, value)
