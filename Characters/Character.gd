extends Node2D
class_name Character

onready var sprite = $Sprite
onready var area = $Area2D
onready var moveTween = $MoveTween
onready var attackTween = $AttackTween
onready var animPlayer = $AnimationPlayer
onready var HUD = $HUD

#stats
var move_range = 1
var attack_range = 1
var health = 100
var power = 34

#move
var path = []
var i = 0
var speed = 1.0/3.0

#attack
var att
var curr

func _ready():
	Master.connect("win",self,"win")
	animPlayer.play("idle")

func color_init(skin):
	sprite.modulate = skin

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("left_click"):
		Master.emit_signal("preview_moves",self)

func disable_collision(collision,node):
	if self != node:
		area.get_node("CollisionShape2D").disabled = collision

func ghost():
	area.input_pickable = false
	animPlayer.stop()
	sprite.position = Vector2(8,6)
	sprite.modulate = Color.gray
	i = 0

func reset():
	animPlayer.play("idle")
	if find_node("Area2D"):
		area.input_pickable = true
	sprite.modulate = Color(1,1,1,1)

func move(new_path):
	area.input_pickable = false
	path = new_path
	move_along_path()

func move_along_path():
	if i < path.size():
		start_tween(moveTween,global_position,path[i],speed)
	else:
		Master.emit_signal("preview_attacks",true)
		Master.moving = false

func _on_MoveTween_completed(_object, _key):
	Master.play_sound("move")
	i += 1
	move_along_path()

func attack(target_pos,target):
	var dir = (global_position - target_pos)/16 #tile size
	curr = global_position
	att = target_pos + (dir * 8)
	
	z_index = 1
	var time = 0.4
	start_tween(attackTween,curr,att,time)
	yield(attackTween,"tween_completed")
	Master.play_sound("attack")
	target.take_damage(power)
	yield(get_tree().create_timer(0.1), "timeout")
	start_tween(attackTween,att,curr,time)
	yield(attackTween,"tween_completed")
	z_index = 0
	
	ghost()
	Master.emit_signal("move_finished")

func start_tween(tween,start_pos,end_pos,time):
	tween.interpolate_property(self,"global_position",start_pos,end_pos,time,tween.TRANS_SINE,tween.EASE_IN_OUT)
	tween.start()

func take_damage(damage):
	health -= damage
	$HUD.update_health(health)
	if health <= 0:
		yield(get_tree().create_timer(0.5),"timeout")
		die()

func die():
	queue_free()

func win():
	animPlayer.play("win")
