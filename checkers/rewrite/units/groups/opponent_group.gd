extends UnitGroup


func take_turn() -> void:
	super()
	#await get_tree().create_timer(0.5).timeout
	if not jumpable_units.is_empty():
		set_selected_unit(jumpable_units.front())
	elif not moveable_units.is_empty():
		set_selected_unit(moveable_units.front())

	for unit: Unit in moveable_units:
		var m = _minimax(unit.available_cells, 3, true)

	if selected_unit:
		selected_unit.move(selected_unit.available_cells.front())


func _minimax(cells: Array, depth: int, is_maximizing_player: bool) -> int:
	if depth == 0:
		return 0

	if is_maximizing_player:
		var max_eval = -INF
		for cell in cells:
			var eval = _minimax(cell, depth - 1, false)
			max_eval = max(max_eval, eval)
		print(max_eval)
		return max_eval
	else:
		var min_eval = INF
		for cell in cells:
			var eval = _minimax(cell, depth - 1, true)
			min_eval = min(min_eval, eval)
		print(min_eval)
		return min_eval


func _on_unit_movement_completed(unit: Unit) -> void:
	super(unit)
	if unit.can_move:
		take_turn()
