extends UnitGroup


func take_turn() -> void:
	super()

	var unit_scores := {}
	for unit: Unit in moveable_units:
		var moves := {}
		for cell in unit.available_cells:
			moves[cell] = _minimax(board.duplicate(true), 3, true, unit, cell)

		var best_score = moves.values().max()
		unit_scores[best_score] = { "unit": unit, "cell": moves[best_score] }

	var best_unit_score = unit_scores.keys().max()
	var move = unit_scores[best_unit_score]
	selected_unit = move["unit"]
	var cell = move["cell"]
	if selected_unit:
		selected_unit.move(cell)


func _minimax(board: Array, depth: int, is_maximizing: bool, unit: Unit, new_cell: Vector2i) -> int:
	var simulated_units := _get_simulated_all_units(board)
	if depth == 0 or simulated_units["player"].is_empty() or simulated_units["enemy"].is_empty():
		return get_board_evaluation(board)

	# TODO: figure out how to simulate jumping over a piece

	board[unit.cell.y][unit.cell.x] = null
	board[new_cell.y][new_cell.x] = unit
	if is_maximizing:
		var max_eval = int(-INF)
		for enemy_unit in _unit_movement.get_moveable_units(board):
			var eval = null
			for cell in enemy_unit.available_cells:
				eval = _minimax(board.duplicate(true), depth - 1, false, enemy_unit, cell)
			max_eval = max(max_eval, eval)
		print(max_eval)
		return max_eval
	else:
		var min_eval = int(INF)
		for player_unit in get_parent().get_node("PlayerGroup")._unit_movement.get_moveable_units(board):
			var eval = null
			for cell in player_unit.available_cells:
				eval = _minimax(board.duplicate(true), depth - 1, true, player_unit, cell)
			min_eval = min(min_eval, eval)
		print(min_eval)
		return min_eval


func get_board_evaluation(board: Array) -> int:
	var simulated_units := _get_simulated_all_units(board)
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


func _get_simulated_all_units(board: Array) -> Dictionary:
	var player_units = []
	var enemy_units = []
	for row in board:
		for cell in row:
			var unit := cell as Unit
			if not unit:
				continue
			if unit.team == Globals.Team.PLAYER:
				player_units.append(unit)
			elif unit.team == Globals.Team.OPPONENT:
				enemy_units.append(unit)

	return { "player": player_units, "enemy": enemy_units }


func _on_unit_movement_completed(unit: Unit, start_cell: Vector2i) -> void:
	super(unit, start_cell)
	if unit.can_move:
		take_turn()
