class_name UnitMovement
extends Node2D


@onready var _parent: UnitGroup = get_parent()


func get_moveable_units() -> void:
	for unit: Unit in _parent.units:
		unit.available_cells.clear()
		for direction in unit.directions:
			var movement_direction: Vector2i = Globals.movement_vectors.get(direction)
			var target_cell = unit.cell + movement_direction
			if not _is_cell_available(unit, movement_direction, target_cell):
				continue

			_parent.moveable_units.append(unit)
			unit.can_move = true
			if not unit.can_jump:
				continue

			_parent.jumpable_units.append(unit)
			for cell in unit.available_cells:
				var squared_distance = unit.cell.distance_squared_to(cell)
				if not squared_distance == 2:
					continue

				unit.available_cells.erase(cell)


func _is_cell_available(unit: Unit, initial_direction: Vector2i, target_cell: Vector2i) -> bool:
	if not _validate_tile(target_cell):
		return false

	for unit_on_board: Unit in _parent.all_units:
		if not unit_on_board.cell == target_cell:
			continue

		if unit_on_board.team == unit.team:
			return false
		else:
			var new_target_cell = target_cell + initial_direction
			if not _can_jump_to_cell(unit, new_target_cell, unit_on_board.cell):
				return false

			unit.available_cells.append(new_target_cell)
			unit.can_jump = true
			unit.units_to_jump_over.append(unit_on_board)
			_check_for_multi_jumps(unit, new_target_cell)
			return true

	# Can make a normal move
	unit.available_cells.append(target_cell)
	return unit.available_cells.size() > 0


func _check_for_multi_jumps(unit: Unit, starting_cell: Vector2i) -> void:
	for direction in unit.directions:
		var movement_direction = Globals.movement_vectors.get(direction)
		var jumped_cell = movement_direction + starting_cell
		var new_target_cell = jumped_cell + movement_direction
		if _can_jump_to_cell(unit, new_target_cell, jumped_cell):
			for unit_on_board: Unit in _parent.all_units:
				if unit_on_board.cell == jumped_cell:
					unit.units_to_jump_over.append(unit_on_board)
					break
			unit.available_cells.append(new_target_cell)
			_check_for_multi_jumps(unit, new_target_cell)


func _can_jump_to_cell(unit: Unit, target_cell: Vector2i, jumped_cell: Vector2i) -> bool:
	if not _validate_tile(target_cell):
		return false

	if _parent.all_units.any(func(x: Unit): return x.cell == target_cell):
		return false

	return _parent.all_units.any(
			func(x: Unit): return x.cell == jumped_cell and not x.team == unit.team
	)


func _validate_tile(tile_pos) -> bool:
	if tile_pos.x < 0 or tile_pos.x > (Globals.GRID_SIZE - 1):
		return false

	if tile_pos.y < 0 or tile_pos.y > (Globals.GRID_SIZE - 1):
		return false

	return true