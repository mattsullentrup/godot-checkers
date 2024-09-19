class_name UnitMovement
extends Node2D


@onready var _parent: UnitGroup = get_parent()


func get_moveable_units() -> void:
	for unit: Unit in _parent.units:
		unit.available_cells.clear()
		for direction in unit.directions:
			_get_unit_normal_moves(unit, direction)
			_get_unit_jump_moves(unit, direction)

		if unit.can_jump:
			_discard_normal_moves(unit)


func _get_unit_normal_moves(unit: Unit, direction: Globals.Direction) -> void:
	var target_cell = unit.cell + Globals.movement_vectors.get(direction)
	if not _is_tile_valid(target_cell):
		return

	var adjacent_unit = _get_adjacent_unit(target_cell)
	if not adjacent_unit == null:
		return

	_parent.moveable_units.append(unit)
	unit.can_move = true
	unit.available_cells.append(target_cell)


func _get_unit_jump_moves(unit: Unit, direction: Globals.Direction) -> void:
	var movement_direction = Globals.movement_vectors.get(direction)
	var adjacent_cell = unit.cell + movement_direction
	var adjacent_unit = _get_adjacent_unit(adjacent_cell)
	if adjacent_unit == null or adjacent_unit.team == unit.team:
		return

	# There is an adjacent enemy, try to jump over it
	var jump_target_cell: Vector2i = adjacent_cell + movement_direction
	if not _can_jump_over_enemy(jump_target_cell, movement_direction, unit, adjacent_unit):
		return

	if not _parent.jumpable_units.has(unit):
		_parent.jumpable_units.append(unit)

	unit.can_jump = true
	unit.can_move = true


func _discard_normal_moves(unit: Unit) -> void:
	for cell in unit.available_cells:
		var squared_distance = unit.cell.distance_squared_to(cell)
		if not squared_distance == 2:
			continue

		unit.available_cells.erase(cell)


func _get_adjacent_unit(target_cell: Vector2i) -> Unit:
	for unit_to_check: Unit in _parent.all_units:
		if unit_to_check.cell == target_cell:
			return unit_to_check

	return null


func _can_jump_over_enemy(
			jump_target_cell: Vector2i, direction: Vector2i, \
			unit: Unit, enemy: Unit) -> bool:
	if not _can_jump_to_cell(unit, jump_target_cell, enemy.cell):
		return false

	if not unit.available_cells.has(jump_target_cell):
		unit.available_cells.append(jump_target_cell)

	var first_jump := JumpData.new(enemy, jump_target_cell)
	var jump_path: Array
	jump_path.append(first_jump)
	unit.jump_paths.append(jump_path)

	var backwards: Vector2i = -direction
	for data in _get_multi_jump_path(unit, jump_target_cell, jump_path, backwards):
		var path := jump_path.duplicate()
		path.append(data)
		unit.jump_paths.append(path)

	return true


func _get_multi_jump_path(unit: Unit, starting_cell: Vector2i, jump_path: Array, backwards: Vector2i) -> Array[JumpData]:
	var valid_data: Array[JumpData]
	for direction in unit.directions:
		var movement_direction = Globals.movement_vectors.get(direction)
		var jumped_cell = movement_direction + starting_cell
		var new_target_cell = jumped_cell + movement_direction
		if not _can_jump_to_cell(unit, new_target_cell, jumped_cell) or movement_direction == backwards:
			continue

		if not unit.available_cells.has(new_target_cell):
			unit.available_cells.append(new_target_cell)

		var jump_data := _create_jump_data(new_target_cell, jumped_cell)
		valid_data.append(jump_data)

	return valid_data


func _create_jump_data(target_cell: Vector2i, jumped_cell: Vector2i) -> JumpData:
	var jump_data := JumpData.new()
	jump_data.target_cell = target_cell
	for unit_on_board: Unit in _parent.all_units:
		if not unit_on_board.cell == jumped_cell:
			continue

		jump_data.jumpable_unit = unit_on_board
		break

	return jump_data


func _can_jump_to_cell(unit: Unit, target_cell: Vector2i, jumped_cell: Vector2i) -> bool:
	if not _is_tile_valid(target_cell):
		return false

	# Cell is occupied
	if _parent.all_units.any(func(x: Unit): return x.cell == target_cell):
		return false

	# Will jump over an enemy, not a teammate
	return _parent.all_units.any(
			func(x: Unit): return x.cell == jumped_cell and not x.team == unit.team
	)


func _is_tile_valid(tile_pos) -> bool:
	if tile_pos.x < 0 or tile_pos.x > (Globals.GRID_SIZE - 1):
		return false

	if tile_pos.y < 0 or tile_pos.y > (Globals.GRID_SIZE - 1):
		return false

	return true
