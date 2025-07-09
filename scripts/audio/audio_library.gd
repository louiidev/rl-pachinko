class_name AudioLibrary extends AudioStreamPlayer2D


enum SoundFxs {
	PegHit,
	BallSpawned,
	PrizeClaimed,
	Click
}

var sfx_streams: Dictionary[SoundFxs, AudioStream] = {
	SoundFxs.PegHit: preload("res://sound_fxs/ball_spawned.mp3"),
	SoundFxs.BallSpawned: preload("res://sound_fxs/peg_hit.mp3"),
	SoundFxs.PrizeClaimed: preload("res://sound_fxs/prize_claimed.mp3"),
	SoundFxs.Click: preload("res://sound_fxs/mouse-click-290204.mp3"),
}
 
func play_sfx(sfx: SoundFxs, volumn_db: float = 0.0) -> void:
	if !self.playing:
		self.play()
		
	var playback: AudioStreamPlaybackPolyphonic = get_stream_playback()
	playback.play_stream(sfx_streams[sfx])

func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 20
