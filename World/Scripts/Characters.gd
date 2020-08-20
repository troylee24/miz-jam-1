extends TileMap

signal preview_moves

var folder_path = "res://Characters/Scenes/"

func _ready():
	init()

func init():
	var used_cells = get_used_cells()
	for i in used_cells.size():
		var cell = get_cellv(used_cells[i])
		var path = folder_path + tile_set.tile_get_name(cell) + ".tscn"
		create(load(path),used_cells[i])
	clear()

func create(type, pos):
	var instance = type.instance()
	instance.global_position = map_to_world(pos)
	instance.connect("preview_moves",self,"preview_moves")
	call_deferred("add_child",instance)
	if name == "Enemy":
		instance.get_node("Area2D").queue_free()
		instance.call_deferred("ghost")
	instance.add_to_group(name)

func preview_moves(character):
	emit_signal("preview_moves",character)
