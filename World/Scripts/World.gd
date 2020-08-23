extends Node2D

onready var startButton = $UI/LeftSide/Panel/MarginContainer/SideBar/StartButton
onready var endTurnButton = $UI/LeftSide/Panel/MarginContainer/SideBar/EndTurnButton

func _ready():
	Master.stop_sound()
	Master.play_sound("background")
	Master.connect("win",self,"win")
	
func win():
	$Particles2D.emitting = true
	$UI/AnimationPlayer.play("win")

func _on_StartButton_pressed():
	$Board/Player1.init()
	$Board/Player2.init()
	startButton.disabled = true
	endTurnButton.disabled = false
	Master.stop_sound()
	Master.play_sound("game")

func _on_RestartButton_pressed():
	get_tree().reload_current_scene()

func _on_EndTurnButton_pressed():
	if !Master.moving:
		endTurnButton.disabled = true
		$Board.change_turn()
		yield(get_tree().create_timer(2), "timeout")
		endTurnButton.disabled = false

func _on_SwitchButton_pressed():
	Master.switch_scene()
