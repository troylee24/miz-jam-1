extends Node2D

func _ready():
	Master.connect("win",self,"win")
	
func win():
	$Particles2D.emitting = true
	$UI/AnimationPlayer.play("win")
