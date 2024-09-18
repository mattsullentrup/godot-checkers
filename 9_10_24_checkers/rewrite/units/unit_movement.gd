class_name UnitMovement
extends Node2D


@onready var _parent: UnitGroup = get_parent()


func get_moveable_units() -> void:
	await get_tree().create_timer(.1).timeout
	for unit: Unit in _parent.units:
		unit.available_cells.clear()
		for direction in unit.directions:
			# Find out if unit can move at all
			var movement_direction: Vector2i = Globals.movement_vectors.get(direction)
			var target_cell = unit.cell + movement_direction
			if not _is_cell_available(unit, movement_direction, target_cell):
				continue

		if unit.available_cells.size() <= 0:
			continue

		_parent.moveable_units.append(unit)
		unit.can_move = true

		_check_if_unit_can_jump(unit)


func _check_if_unit_can_jump(unit):
	if not unit.can_jump:
		return false

	_parent.jumpable_units.append(unit)
	# Remove any normal moves from the units list of available moves
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
			if _can_jump_over_enemy(target_cell, initial_direction, unit, unit_on_board):
				return true

	# Can make a normal move
	unit.available_cells.append(target_cell)
	return true


func _can_jump_over_enemy(
			target_cell: Vector2i, initial_direction: Vector2i, \
			unit: Unit, enemy: Unit) -> bool:
	var new_target_cell = target_cell + initial_direction
	if not _can_jump_to_cell(unit, new_target_cell, enemy.cell):
		return false

	unit.can_jump = true
	unit.available_cells.append(new_target_cell)

	var first_jump := JumpData.new(enemy, new_target_cell)
	var jump_path: Array
	jump_path.append(first_jump)

	var backwards: Vector2i = target_cell - new_target_cell
	for data in _get_valid_jump_data(unit, new_target_cell, jump_path, backwards):
		var path := jump_path.duplicate()
		path.append(data)
		unit.jump_paths.append(path)

	return true


func _get_valid_jump_data(unit: Unit, starting_cell: Vector2i, jump_path: Array, backwards: Vector2i) -> Array[JumpData]:
	var valid_data: Array[JumpData]
	for direction in unit.directions:
		var movement_direction = Globals.movement_vectors.get(direction)
		var jumped_cell = movement_direction + starting_cell
		var new_target_cell = jumped_cell + movement_direction
		if not _can_jump_to_cell(unit, new_target_cell, jumped_cell) or movement_direction == backwards:
			continue

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
	if not _validate_tile(target_cell):
		return false

	# Cell is occupied
	if _parent.all_units.any(func(x: Unit): return x.cell == target_cell):
		return false

	# Will jump over an enemy, not a teammate
	return _parent.all_units.any(
			func(x: Unit): return x.cell == jumped_cell and not x.team == unit.team
	)


func _validate_tile(tile_pos) -> bool:
	if tile_pos.x < 0 or tile_pos.x > (Globals.GRID_SIZE - 1):
		return false

	if tile_pos.y < 0 or tile_pos.y > (Globals.GRID_SIZE - 1):
		return false

	return true
