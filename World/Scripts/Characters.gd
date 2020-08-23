extends TileMap

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
	call_deferred("add_child",instance)
	if name == "Player2":
		instance.call_deferred("ghost")
	instance.add_to_group(name)
