extends Node2D
class_name Character

signal preview_moves

onready var sprite = $Sprite
onready var area = $Area2D
onready var animPlayer = $AnimationPlayer

var move_range = 1
var attack_range = 1

var path = []
var i = 0
var speed = 3

func _ready():
	animPlayer.play("idle")

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("left_click"):
		emit_signal("preview_moves",self)

func ghost():
	animPlayer.stop()
	sprite.position = Vector2(8,6)
	if find_node("Area2D"):
		area.input_pickable = false
	sprite.modulate = Color.gray
	i = 0

func reset():
	animPlayer.play("idle")
	if find_node("Area2D"):
		area.input_pickable = true
	sprite.modulate = Color(1,1,1,1)

func move(new_path):
	path = new_path
	move_along_path()

func move_along_path():
	if i < path.size():
		$Tween.interpolate_property(self,"global_position",global_position,path[i],1.0/speed,$Tween.TRANS_SINE,$Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		ghost()

func _on_Tween_tween_completed(_object, _key):
	Master.play_sound("move",-5)
	i += 1
	move_along_path()

func attack():
	ghost()

