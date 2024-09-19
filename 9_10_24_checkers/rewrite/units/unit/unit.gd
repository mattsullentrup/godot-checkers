class_name Unit
extends Node2D


const MOVEMENT_DURATION = 0.5

signal unit_defeated(unit: Unit)
signal movement_completed(unit: Unit)

@export var directions: Array[Globals.Direction]
@export var normal_color: Color
@export var king_color: Color
@export var team: Globals.Team

# INFO: This is only used for other nodes to display/check if unit can move to click
var available_cells: Array[Vector2i]
var jump_paths: Array[Array]
var can_move: bool
var can_jump: bool
var normal_move_tween: Tween
var jump_path_tween: Tween
var cell: Vector2i
var color: Color

@export var is_king: bool:
	set = _set_is_king

@onready var _unit_visuals: UnitVisuals = %UnitVisuals


func _ready() -> void:
	color = normal_color


func explode() -> void:
	unit_defeated.emit(self)
	_unit_visuals.explode()
	await $GPUParticles2D.finished
	queue_free()


func move(new_cell: Vector2i) -> void:
	z_index += 1

	if can_jump:
		_find_jump_path(new_cell)
	else:
		_tween_move_normally(new_cell)


func _tween_move_normally(new_cell: Vector2i) -> void:
	if normal_move_tween:
		normal_move_tween.kill()

	normal_move_tween = create_tween()
	_move_tween(new_cell, normal_move_tween)

	normal_move_tween.tween_callback(_finish_moving.bind(new_cell))


func _find_jump_path(new_cell: Vector2i) -> void:
	var possible_paths: Array[Array]
	possible_paths = jump_paths.filter(
			func(path: Array): return path.any(
					func(x: JumpData): return x.target_cell == new_cell))

	var largest_path_size: int = 0
	#var longest_path: Array
	for path in possible_paths:
		if path.size() > largest_path_size:
			#longest_path = path
			largest_path_size = path.size()

	var smallest_cell_index: int = largest_path_size - 1
	var shortest_path_to_new_cell: Array
	for path in possible_paths:
		for data: JumpData in path:
			if not data.target_cell == new_cell:
				continue

			var new_cell_index = path.find(data)
			if new_cell_index < smallest_cell_index:
				shortest_path_to_new_cell = path
				smallest_cell_index = new_cell_index

	var index = possible_paths.find(shortest_path_to_new_cell)
	var path_to_take = possible_paths[index]

	_jump_tween_through_path(path_to_take, new_cell)

	#for path: Array in jump_paths:
		#for data: JumpData in path:
			#if not data.target_cell == new_cell:
				#continue
#
			#_jump_tween_through_path(path, new_cell)
			#return


func _jump_tween_through_path(path: Array, new_cell: Vector2i) -> void:
	_jump_tween(path.front())

	if jump_path_tween:
		await jump_path_tween.finished

	var current_cell = Navigation.world_to_cell(global_position)
	_update_jump_paths(current_cell)
	_update_available_cells()

	# Arrived at clicked cell, even if not end of path
	if current_cell == new_cell:
		_finish_moving(new_cell)
	else:
		_jump_tween_through_path(path, new_cell)
		return



func _update_available_cells():
	available_cells.clear()
	for path in jump_paths:
		for data: JumpData in path:
			if not available_cells.has(data.target_cell):
				available_cells.append(data.target_cell)


func _jump_tween(jump_data: JumpData) -> void:
	if jump_path_tween:
		jump_path_tween.kill()

	jump_path_tween = create_tween()
	_move_tween(jump_data.target_cell, jump_path_tween)
	_unit_visuals.jump_tween(jump_path_tween)

	await jump_path_tween.finished
	jump_data.jumpable_unit.explode()


func _update_jump_paths(current_cell):
	# Delete any path that doesn't start at the current cell
	jump_paths = jump_paths.filter(
		func(path: Array): return path.front().target_cell == current_cell)

	# Update any remaining jump paths so they start at the current_cell
	for jump_path: Array in jump_paths:
		jump_path.remove_at(0)


func _move_tween(new_cell, tween) -> void:
	var world_pos = Navigation.cell_to_world(new_cell)
	tween.tween_property(self, "global_position", Vector2(world_pos), MOVEMENT_DURATION) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_OUT)


func _finish_moving(new_cell: Vector2i) -> void:
	cell = new_cell
	movement_completed.emit(self)
	z_index -= 1


func _set_is_king(value) -> void:
	is_king = value
	color = king_color
	for vector in Globals.movement_vectors:
		#var movement_direction = Globals.movement_vectors.get(vector)
		if not directions.has(vector):
			directions.append(vector)
