extends AStar_Path

var turn = true
var node = null
var node_pos = null
var offense = []
var defense = []
var locked_tiles = []
var move_tiles = []
var attack_tiles = []

var can_move = false

func get_turn(value):
	if value:
		return "Player"
	else:
		return "Enemy"

func change_turn():
	yield(get_tree().create_timer(2), "timeout")
	Master.play_sound("change_turn",-5)
	stop_preview_all()
	get_tree().call_group(get_turn(!turn),"reset")
	turn = !turn
	if get_turn(turn) == "Enemy":
		set_process_input(false)
		$AI.play()
	else:
		set_process_input(true)

func _ready():
	$Player.connect("preview_moves",self,"preview_moves")
	$Enemy.connect("preview_moves",self,"preview_moves")
	$AI.connect("ai_move",self,"ai_move")

func ai_move(character):
	preview_moves(character)
	randomize()
	var random_move = randi() % move_tiles.size()
	action(move_tiles[random_move])

func _input(event):
	if event.is_action_pressed("right_click") && can_move:
		can_move = false
		stop_preview()
	elif event.is_action_pressed("left_click") && can_move:
		can_move = false
		action()

func action(new_pos = null):
	if !new_pos:
		new_pos = world_to_map(get_global_mouse_position())
	if move_tiles.has(new_pos):
		#move to mouse_pos
		var new_path = convert_path(path(node_pos,new_pos))
		node.move(new_path)
		stop_preview()
		change_cell(new_pos,1)
		locked_tiles.append(new_pos)
	elif attack_tiles.has(new_pos):
		#attack at mouse_pos *without moving*
		node.attack()
		stop_preview()
		change_cell(node_pos,1)
		locked_tiles.append(node_pos)
	else:
		stop_preview()
		
	if locked_tiles.size() == offense.size() + 1:
		change_turn()

func convert_path(path):
	var new_path = []
	for point in path:
		new_path.append(map_to_world(Vector2(point.x,point.y)))
	return new_path

func preview_moves(character):
	node = character
	node_pos = world_to_map(node.global_position)
	stop_preview()
	#initialize variables
	var move_range = node.move_range
	
	#evaluate square with side-length move_range
	for i in range (-move_range, move_range + 1):
		for j in range (-move_range, move_range + 1):
			var new_pos = node_pos + Vector2(i,j)
			#can move if: tilemap has position, position not occupied, and can be reached in move_range
			if used_cells.has(new_pos) && !offense.has(new_pos) && !defense.has(new_pos) && path_size(node_pos,new_pos) <= move_range:
				change_cell(new_pos,1)
				move_tiles.append(new_pos)
	
	preview_attacks()
	can_move = true

func preview_attacks():
	var attack_range = node.attack_range
	for i in range (-attack_range, attack_range + 1):
		for j in range (-attack_range, attack_range + 1):
			var new_pos = node_pos + Vector2(i,j)
			if used_cells.has(new_pos) && !offense.has(new_pos):
				if defense.has(new_pos):
					change_cell(new_pos,2)
					attack_tiles.append(new_pos)
#				elif new_pos != node_pos:
#					change_cell(new_pos,3)

func stop_preview():
	offense = convert_coord(get_tree().get_nodes_in_group(get_turn(turn)))
	offense.erase(node_pos)
	defense = convert_coord(get_tree().get_nodes_in_group(get_turn(!turn)))
	
	for cell in used_cells:
		if !locked_tiles.has(cell):
			if defense.has(cell):
				if get_cellv(cell) == 2:
					change_cell(cell,0)
			else:
				change_cell(cell,0)
	
	move_tiles.resize(0)
	attack_tiles.resize(0)

func stop_preview_all():
	for cell in used_cells:
		change_cell(cell,0)
	
	locked_tiles.resize(0)
					
func convert_coord(array):
	var new_array = []
	for element in array:
		new_array.append(world_to_map(element.global_position))
	return new_array

func change_cell(pos,id):
	set_cell(pos.x,pos.y,id)
