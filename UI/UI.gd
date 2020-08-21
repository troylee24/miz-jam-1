extends Control

onready var player = $Turns/PlayerTurn
onready var enemy = $Turns/EnemyTurn
onready var leftArrow = $Turns/Turn/LeftArrow
onready var rightArrow = $Turns/Turn/RightArrow

func _ready():
	set_turn(true)
	
func set_turn(turn):
	lighten(player,turn)
	lighten(leftArrow,turn)
	lighten(enemy,!turn)
	lighten(rightArrow,!turn)

func lighten(label,turn):
	if turn:
		label.modulate = Color(1,1,1,1)
	else:
		label.modulate = Color(1,1,1,0.5)
		
