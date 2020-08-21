extends Node2D

func _ready():
	$Board.connect("change_turn",$UI,"set_turn")
