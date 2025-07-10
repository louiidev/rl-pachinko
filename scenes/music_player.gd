extends AudioStreamPlayer2D


enum MusicStream {
	MainMenu,
	Gameplay
}

@onready var music_streams: Dictionary[MusicStream, AudioStream] = {
	MusicStream.MainMenu: preload("res://music/Destiny Eclipse Journey.wav"),
}


func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	
	play_song(MusicStream.MainMenu)
	


var tween: Tween


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("settings"):
		tween.stop()
	
func play_song(song: MusicStream):
	if !self.playing:
		self.play()
	var playback: AudioStreamPlaybackPolyphonic = get_stream_playback()
	
	playback.play_stream(music_streams[song])
	var bus_index:= AudioServer.get_bus_index("Music")
	tween = create_tween()
	var start_volume:= AudioServer.get_bus_volume_linear(bus_index)
	AudioServer.set_bus_volume_linear(bus_index, 0)
	
	tween.tween_method(
		func(volume): AudioServer.set_bus_volume_linear(bus_index, volume),
		0.0,  # from
		start_volume,          # to (in dB)
		10.0             # duration in seconds
	)
	
	
	
