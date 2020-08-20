extends Node

func play_sound(sound,volume):
	var audio = AudioStreamPlayer.new()
	var path = ""
	match sound:
		"move":
			path = "res://Sounds/chess_move.wav"
		"change_turn":
			path = "res://Sounds/chime.wav"
	audio.stream = load(path)
	audio.volume_db = volume
	audio.connect("finished",audio,"queue_free")
	add_child(audio)
	audio.play()
