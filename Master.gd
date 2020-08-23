extends Node

signal preview_moves
signal preview_attacks
signal move_finished
signal change_turn
signal win

var scene = 2
var moving = false

func switch_scene():
	get_tree().change_scene("res://World/Scenes/World" + str(scene) + ".tscn")
	scene += 1
	if scene > 5:
		scene = 1

func play_sound(sound):
	var audio = AudioStreamPlayer.new()
	audio.connect("finished",audio,"queue_free")
	var path = ""
	var volume = 0
	match sound:
		"background":
			path = "res://Sounds/theme-6.ogg"
			volume = -15
			audio.connect("finished",self,"play_sound",["background"])
		"game":
			path = "res://Sounds/theme-2.ogg"
			volume = -10
			audio.connect("finished",self,"play_sound",["game"])
		"move":
			path = "res://Sounds/chess_move.wav"
			volume = -5
		"change_turn":
			path = "res://Sounds/chime.wav"
			volume = -5
		"attack":
			path = "res://Sounds/sword.wav"
			volume = -5
		"victory":
			path = "res://Sounds/victory.wav"
			volume = -10
			audio.connect("finished",self,"play_sound",["end"])
			set_process_input(false)
		"end":
			emit_signal("win")
			path = "res://Sounds/theme-4.ogg"
			volume = -10
			audio.connect("finished",self,"play_sound",["end"])
	audio.stream = load(path)
	audio.volume_db = volume
	add_child(audio)
	audio.play()

func stop_sound():
	for node in get_children():
		node.queue_free()
