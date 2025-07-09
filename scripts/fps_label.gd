extends Label



func _process(_delta) -> void:
	var fps:= Engine.get_frames_per_second() 
	text= "FPS: " + str(fps)
