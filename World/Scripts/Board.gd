extends AStar_Path

#current turn; true - player1, false - player2
var turn = true
var offense = []
var defense = []
var locked_tiles = []

#current node
var node = null
var node_pos = null
var move_tiles = []
var attack_tiles = []
var second_move = false

#TURN FUNCTIONS
func get_turn(value):
	if value:
		return "Player1"
	else:
		return "Player2"

func change_turn():
	get_tree().call_group(get_turn(turn),"ghost")
	yield(get_tree().create_timer(0.5), "timeout")
	if get_tree().get_nodes_in_group(get_turn(!turn)).size() == 0:
		get_parent().endTurnButton.disabled = true
		get_tree().call_group(get_turn(turn),"ghost")
		Master.stop_sound()
		yield(get_tree().create_timer(0.25), "timeout")
		Master.play_sound("victory")
	else:
		yield(get_tree().create_timer(0.25), "timeout")
		stop_preview_all()
		turn = !turn
		get_tree().call_group(get_turn(turn),"reset")
		Master.emit_signal("change_turn",turn)
		Master.play_sound("change_turn")

#INITIALIZATION
func _ready():
	Master.connect("preview_moves",self,"node_init")
	Master.connect("preview_attacks",self,"preview_attacks")
	Master.connect("move_finished",self,"move_finished")

#ACTION FUNCTIONS
func _input(event):
	if node:
		if event.is_action_pressed("right_click") && !second_move:
			print("here")
			stop_preview()
		elif event.is_action_pressed("left_click"):
			action()

func action(new_pos = null):
	#if player input
	if !new_pos:
		new_pos = world_to_map(get_global_mouse_position())
	
	if !second_move:
		#valid move/attack
		if move_tiles.has(new_pos) || attack_tiles.has(new_pos):
			#valid move
			if move_tiles.has(new_pos):
				if node_pos == new_pos:
					node.ghost()
					move_finished()
				else:
					Master.moving = true
					var new_path = convert_path(path(node_pos,new_pos))
					node.move(new_path)
					get_tree().call_group(get_turn(turn),"disable_collision",true,node)
					node_pos = new_pos
					stop_preview()
					change_cell(new_pos,1)
					second_move = true
			#valid attack *without moving*
			elif attack_tiles.has(new_pos):
				new_pos = map_to_world(new_pos)
				for opponent in get_tree().get_nodes_in_group(get_turn(!turn)):
					if opponent.global_position == new_pos:
						node.attack(new_pos,opponent)
						break
				stop_preview()
				change_cell(node_pos,1)
				get_tree().call_group(get_turn(turn),"disable_collision",true,node)
				second_move = true
		elif !second_move: #left-clicked outside of valid move/attack range
			stop_preview()
	else:
		if node_pos == new_pos || get_cellv(new_pos) == 2:
			if node_pos == new_pos:
				node.ghost()
				move_finished()
			elif get_cellv(new_pos) == 2:
				new_pos = map_to_world(new_pos)
				for opponent in get_tree().get_nodes_in_group(get_turn(!turn)):
					if opponent.global_position == new_pos:
						node.attack(new_pos,opponent)
						break
				stop_preview()
				change_cell(node_pos,1)
				get_tree().call_group(get_turn(turn),"disable_collision",true,node)

func node_init(character):
	node = character
	node_pos = world_to_map(node.global_position)
	offense = convert_coord(get_tree().get_nodes_in_group(get_turn(turn)))
	offense.erase(node_pos)
	defense = convert_coord(get_tree().get_nodes_in_group(get_turn(!turn)))
	stop_preview()
	preview_moves()

func preview_moves():
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

func preview_attacks(second = false):
	second_move = second
		
	var attack_range = node.attack_range
	for i in range (-attack_range, attack_range + 1):
		for j in range (-attack_range, attack_range + 1):
			var new_pos = node_pos + Vector2(i,j)
			if used_cells.has(new_pos) && !offense.has(new_pos):
				if defense.has(new_pos):
					change_cell(new_pos,2)
					attack_tiles.append(new_pos)
				elif new_pos != node_pos && !second_move:
					change_cell(new_pos,3)
	
	if second_move:
		if attack_tiles.empty():
			node.ghost()
			move_finished()

#RESET FUNCTIONS
func move_finished():
	get_tree().call_group(get_turn(turn),"disable_collision",false,node)
	stop_preview()
	change_cell(node_pos,1)
	locked_tiles.append(node_pos)
	if locked_tiles.size() == offense.size() + 1:
		change_turn()

func stop_preview():
	#ignore occupied tiles (both allies and opponents)
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

#HELPER FUNCTIONS
func convert_coord(array):
	var new_array = []
	for element in array:
		new_array.append(world_to_map(element.global_position))
	return new_array

func convert_path(path):
	var new_path = []
	for point in path:
		new_path.append(map_to_world(Vector2(point.x,point.y)))
	return new_path

func change_cell(pos,id):
	set_cell(pos.x,pos.y,id)
