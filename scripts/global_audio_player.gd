extends Node2D



@onready var sfx_player: AudioLibrary = $SfxPlayer


func play_sound_fx(sfx: AudioLibrary.SoundFxs, volumn_db: float = 0.0):
	sfx_player.play_sfx(sfx, volumn_db)

func _ready() -> void:
	Game.sound_fx_request.connect(play_sound_fx)

	pass
