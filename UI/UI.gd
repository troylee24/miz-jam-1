extends Control

onready var player1 = $Turns/Player1
onready var player2 = $Turns/Player2
onready var leftArrow = $Turns/Turn/LeftArrow
onready var rightArrow = $Turns/Turn/RightArrow

func _ready():
	Master.connect("change_turn",self,"set_turn")
	set_turn(true)
	
func set_turn(turn):
	lighten(player1,turn)
	lighten(leftArrow,turn)
	lighten(player2,!turn)
	lighten(rightArrow,!turn)

func lighten(label,turn):
	if turn:
		label.modulate = Color(1,1,1,1)
	else:
		label.modulate = Color(1,1,1,0.5)
		
