extends Node

signal ai_move

func play():
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		yield(get_tree().create_timer(1), "timeout")
		emit_signal("ai_move",enemy)
