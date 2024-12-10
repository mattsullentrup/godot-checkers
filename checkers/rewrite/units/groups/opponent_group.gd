extends UnitGroup


func take_turn() -> void:
	super()

	#var board: Array = get_parent().get_board_state()
	var unit_scores := {}
	for unit: Unit in moveable_units:
		var moves := {}
		for cell in unit.available_cells:
			moves[cell] = _minimax(3, true, unit, cell)

		var best_score = moves.values().max()
		unit_scores[best_score] = { "unit": unit, "cell": moves[best_score] }

	var best_unit_score = unit_scores.keys().max()
	var move = unit_scores[best_unit_score]
	selected_unit = move["unit"]
	var cell = move["cell"]
	if selected_unit:
		selected_unit.move(cell)


func _minimax(depth: int, is_maximizing_player: bool, unit: Unit, new_cell: Vector2i) -> int:
	if depth == 0:
		return 0

	#board[unit.cell.y][unit.cell.x] = null
	#board[new_cell.y][new_cell.x] = unit
	if is_maximizing_player:
		var pretend_unit_group: UnitGroup = self.duplicate()
		pretend_unit_group._unit_movement.get_moveable_units()
		var max_eval = int(-INF)
		# TODO: change unit movement to take in the board array as an argument so we can calculate
		# future board states
		for cell in cells:
			var eval = _minimax(cell, depth - 1, false)
			max_eval = max(max_eval, eval)
		print(max_eval)
		return max_eval
	else:
		var min_eval = int(INF)
		for cell in cells:
			var eval = _minimax(cell, depth - 1, true)
			min_eval = min(min_eval, eval)
		print(min_eval)
		return min_eval


func get_board_evaluation(board: Array) -> int:
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


func get_board_simulation() -> Array:
	var board := []
	for y in Globals.GRID_SIZE:
		var row := []
		for x in Globals.GRID_SIZE:
			row.append(null)
		board.append(row)

	for unit: Unit in all_units:
		board[unit.cell.y][unit.cell.x] = unit.duplicate()

	return board


func _on_unit_movement_completed(unit: Unit) -> void:
	super(unit)
	if unit.can_move:
		take_turn()
