class_name Main
extends Node2D


enum Team {
	PLAYER_ONE = 1,
	PLAYER_TWO = 2
}

const CELL_SIZE = 128
const GRID_SIZE = 8
const INVALID_TILE = -Vector2i.ONE

var pieces: Array[Piece]
var highlighted_tiles: Array[Vector2i]
var focused_piece: Piece

var _mouse_pos: Vector2i
#var _whose_turn := Team.PLAYER_ONE

#@onready var _visuals: Visuals = %Visuals


func _ready() -> void:
	_create_pieces(0, 3, Team.PLAYER_TWO)
	_create_pieces(5, GRID_SIZE, Team.PLAYER_ONE)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_get_hovered_piece()
	elif event is InputEventMouseButton and event.is_action_pressed("click"):
		if _mouse_pos in highlighted_tiles:
			_move_piece()
			return

		_get_clicked_piece()


func _process(_delta: float) -> void:
	_get_mouse_pos()


func _get_mouse_pos() -> void:
	var global_mouse_pos := get_global_mouse_position()
	if global_mouse_pos.x < 0 or global_mouse_pos.x > CELL_SIZE * GRID_SIZE:
		return

	@warning_ignore("integer_division")
	_mouse_pos = Vector2i(
			_round_down(global_mouse_pos.x) / CELL_SIZE,
			_round_down(global_mouse_pos.y) / CELL_SIZE
	)


func _get_hovered_piece() -> void:
	for piece in pieces:
		if piece.position == _mouse_pos:
			piece.is_hovered = true
		else:
			piece.is_hovered = false


func _get_clicked_piece() -> void:
	for piece in pieces:
		if piece.position == _mouse_pos:
			focused_piece = piece
			highlighted_tiles.clear()
			_get_available_moves()


func _get_available_moves() -> void:
	if focused_piece.team == Team.PLAYER_ONE:
		var upper_left := _get_tile(focused_piece.position + -Vector2i.ONE)
		var upper_right := _get_tile(focused_piece.position + Vector2i(1, -1))
		if not upper_left == INVALID_TILE:
			highlighted_tiles.append(upper_left)

		if not upper_right == INVALID_TILE:
			highlighted_tiles.append(upper_right)
	elif focused_piece.team == Team.PLAYER_TWO:
		var lower_left := _get_tile(focused_piece.position + Vector2i(-1, 1))
		var lower_right := _get_tile(focused_piece.position + Vector2i.ONE)
		if not lower_left == INVALID_TILE:
			highlighted_tiles.append(lower_left)

		if not lower_right == INVALID_TILE:
			highlighted_tiles.append(lower_right)


func _get_tile(tile_pos: Vector2i) -> Vector2i:
	if tile_pos.x < 0 or tile_pos.x > (GRID_SIZE - 1):
		return INVALID_TILE

	if tile_pos.y < 0 or tile_pos.y > (GRID_SIZE - 1):
		return INVALID_TILE

	for piece in pieces:
		if piece.position == tile_pos:
			if focused_piece.team == piece.team:
				return INVALID_TILE
			else:
				# Can jump over an opponent piece
				var direction := tile_pos - focused_piece.position
				return _get_tile(tile_pos + direction)

	return tile_pos


func _move_piece() -> void:
	var distance := _mouse_pos - focused_piece.position
	if distance.abs() > Vector2i.ONE:
		var jumped_tile := _mouse_pos - (distance / 2)
		for piece in pieces:
			if piece.position == jumped_tile:
				pieces.erase(piece)
				break

	focused_piece.position = _mouse_pos
	focused_piece = null
	highlighted_tiles.clear()


func _create_pieces(start_y: int, end_y: int, team: Team) -> void:
	for y in range(start_y, end_y):
		var start = 1 if y in [1, 5, 7] else 0
		for x in range(start, GRID_SIZE, 2):
			var piece = Piece.new()
			piece.position = Vector2i(x, y)
			piece.team = team
			pieces.append(piece)


func _round_down(num: float) -> int:
	@warning_ignore("narrowing_conversion")
	return num - (int(num) % CELL_SIZE)


class Piece:
	var position: Vector2i
	var team := Team.PLAYER_ONE
	var is_hovered := false
