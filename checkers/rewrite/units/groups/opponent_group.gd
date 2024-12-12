extends UnitGroup


func take_turn() -> void:
	super()

	var unit_scores := {}
	for unit: Unit in moveable_units:
		var moves := {}
		for cell in unit.available_cells:
			moves[cell] = _minimax(board, 3, true)

		var best_score = moves.values().max()
		var best_cell = moves.find_key(best_score)
		#unit_scores[best_score] = { "unit": unit, "cell": best_cell }
		unit_scores[unit] = { "score": best_score, "cell": best_cell }

	#var best_unit_score = unit_scores.keys().max()
	#var move = unit_scores[best_unit_score]
	#selected_unit = move["unit"]
	#var cell = move["cell"]
	var scores = []
	var cell
	var best = int(-INF)
	for move_data in unit_scores.values():
		if move_data["score"] > best:
			best = move_data["score"]
			cell = move_data["cell"]
	if selected_unit:
		selected_unit.move(cell)


func _minimax(board_state: Array, depth: int, is_maximizing: bool) -> int:
	var simulated_units := get_all_units(board_state)
	if depth == 0 or simulated_units["player"].is_empty() or simulated_units["enemy"].is_empty():
		return get_board_evaluation(board_state)

	# TODO: figure out how to simulate jumping over a piece

	# Do this to avoid fucking with the unit's cell and available moves when sending it to
	# UnitMovement to reevaluate it's position
	# We want all the units to be how they were right as the turn started
	# Array.duplicate(deepcopy: true) isn't enough because it doesn't copy the nested array elements
	# NOTE: Its still busted fuck yo ucomputer
	_duplicate_units(board_state)

	if is_maximizing:
		var max_eval = int(-INF)
		var current_moveable_units = _unit_movement.get_moveable_units(board_state)
		for enemy_unit in current_moveable_units:
			var new_unit = enemy_unit.duplicate()
			var eval = null
			for cell in enemy_unit.available_cells:
				var original_cell = enemy_unit.cell
				_simulate_move(cell, enemy_unit, board_state)
				eval = _minimax(board_state, depth - 1, false)
				_simulate_move(original_cell, enemy_unit, board_state)
			max_eval = max(max_eval, eval)
		print(max_eval)
		return max_eval
	else:
		var min_eval = int(INF)
		for player_unit in get_parent().get_node("PlayerGroup")._unit_movement.get_moveable_units(board_state):
			var eval = null
			for cell in player_unit.available_cells:
				var original_cell = player_unit.cell
				_simulate_move(cell, player_unit, board_state)
				eval = _minimax(board_state, depth - 1, true)
				_simulate_move(original_cell, player_unit, board_state)
			min_eval = min(min_eval, eval)
		print(min_eval)
		return min_eval


func get_board_evaluation(board_state: Array) -> int:
	var simulated_units := get_all_units(board_state)
	var player_units = simulated_units["player"]
	var enemy_units = simulated_units["enemy"]
	var player_kings: int = 0
	var enemy_kings: int = 0
	for unit in player_units:
		if unit.is_king:
			player_kings += 1

	for unit in enemy_units:
		if unit.is_king:
			enemy_kings += 1

	return player_units.size() - enemy_units.size() \
			+ (player_kings * 1.5 - enemy_kings * 1.5)


func _simulate_move(new_cell: Vector2i, unit: Unit, board_state: Array[Array]) -> void:
	board_state[unit.cell.y][unit.cell.x] = null
	board_state[new_cell.y][new_cell.x] = unit
	unit.cell = new_cell


func _duplicate_units(board_state: Array[Array]) -> void:
	for row in board_state:
		for cell in row:
			var unit := cell as Unit
			if unit:
				unit = unit.duplicate()


func _on_unit_movement_completed(unit: Unit, start_cell: Vector2i) -> void:
	super(unit, start_cell)
	if unit.can_move:
		take_turn()
