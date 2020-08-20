extends TileMap
class_name AStar_Path

onready var astar = AStar.new()
onready var used_cells = get_used_cells()

func _ready():
	add_points()
	connect_points()
	
func add_points():
	for i in used_cells.size():
		var cell = used_cells[i]
		astar.add_point(id(cell),Vector3(cell.x,cell.y,0))

func connect_points():
	for i in used_cells.size():
		var cell = used_cells[i]
		var neighbors = [Vector2(0,1), Vector2(1,0), Vector2(0,-1), Vector2(-1,0)]
		for neighbor in neighbors:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(id(cell),id(next_cell),false)

func path(start,end):
	var path = astar.get_point_path(id(start),id(end))
	path.remove(0)
	return path

func path_size(start,end):
	return astar.get_point_path(id(start),id(end)).size() - 1

func id(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + a
