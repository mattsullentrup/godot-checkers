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

var is_king: bool:
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
		if normal_move_tween:
			normal_move_tween.kill()

		normal_move_tween = create_tween()
		_move_tween(new_cell, normal_move_tween)

		normal_move_tween.tween_callback(_finish_moving.bind(new_cell))


func _find_jump_path(new_cell: Vector2i) -> void:
	for path: Array in jump_paths:
		for data: JumpData in path:
			if not data.target_cell == new_cell:
				continue

			_jump_tween_through_path(path, new_cell)


func _jump_tween_through_path(path: Array, new_cell: Vector2i) -> void:
	for data: JumpData in path:
		if jump_path_tween:
			jump_path_tween.kill()

		jump_path_tween = create_tween()
		_move_tween(data.target_cell, jump_path_tween)
		_unit_visuals.jump_tween(jump_path_tween)

		await jump_path_tween.finished
		data.jumped_unit.explode()

	_finish_moving(new_cell)


func _move_tween(new_cell, tween) -> void:
	var world_pos = Navigation.cell_to_world(new_cell)
	tween.tween_property(self, "global_position", Vector2(world_pos), MOVEMENT_DURATION) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_OUT)


func _finish_moving(new_cell: Vector2i) -> void:
	cell = new_cell
	movement_completed.emit(self)
	z_index -= 1


func _set_is_king(_value) -> void:
	for vector in Globals.movement_vectors:
		#var movement_direction = Globals.movement_vectors.get(vector)
		if not directions.has(vector):
			directions.append(vector)
