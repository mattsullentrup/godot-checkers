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
var whose_turn := Team.PLAYER_ONE
var _mouse_pos: Vector2i
var _jumped_this_turn := false
var _can_jump_either_dir: Array[bool]


func _ready() -> void:
	_create_pieces(0, 3, Team.PLAYER_TWO)
	_create_pieces(5, GRID_SIZE, Team.PLAYER_ONE)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_get_hovered_piece()
	elif event is InputEventMouseButton and event.is_action_pressed("click"):
		if _mouse_pos in highlighted_tiles:
			_move_piece()
			_start_next_turn()
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
		if piece.position == _mouse_pos and piece.team == whose_turn:
			piece.is_hovered = true
		else:
			piece.is_hovered = false


func _get_clicked_piece() -> void:
	for piece in pieces:
		if piece.position == _mouse_pos and piece.team == whose_turn:
			_can_jump_either_dir.clear()
			focused_piece = piece
			highlighted_tiles.clear()
			_get_available_moves()
			return


func _get_available_moves() -> void:
	if focused_piece.team == Team.PLAYER_ONE:
		_determine_tile_type(-Vector2i.ONE)
		_determine_tile_type(Vector2i(1, -1))
	elif focused_piece.team == Team.PLAYER_TWO:
		_determine_tile_type(Vector2i(-1, 1))
		_determine_tile_type(Vector2i.ONE)


func _determine_tile_type(direction: Vector2i) -> void:
	var diagonal_tile = focused_piece.position + direction
	var tile := _get_tile(diagonal_tile)
	if not tile == INVALID_TILE:
		highlighted_tiles.append(tile)

	if tile == diagonal_tile or tile == INVALID_TILE:
		_can_jump_either_dir.append(false)
	else:
		_can_jump_either_dir.append(true)


func _get_tile(tile_pos: Vector2i) -> Vector2i:
	if not _validate_tile(tile_pos):
		return INVALID_TILE

	for piece in pieces:
		if piece.position == tile_pos:
			if focused_piece.team == piece.team:
				return INVALID_TILE
			else:
				# This is where we need to find out if there is an opponent piece on the other side
				# of a diagonal opponent piece. Currently we keep going deeper recursively because
				# an opponent piece is diagonally placed

				# There is an opponent piece in diagonal tile
				# Check if it can be jumped
				var direction := tile_pos - focused_piece.position
				return _get_tile(tile_pos + direction)

	# Can move normally or jump to this tile
	return tile_pos


func _validate_tile(tile_pos) -> bool:
	if tile_pos.x < 0 or tile_pos.x > (GRID_SIZE - 1):
		return false

	if tile_pos.y < 0 or tile_pos.y > (GRID_SIZE - 1):
		return false

	return true


func _move_piece() -> void:
	if not _jumped_this_turn:
		_determine_if_jumping()
	focused_piece.position = _mouse_pos
	highlighted_tiles.clear()
	_can_jump_either_dir.clear()


func _determine_if_jumping() -> void:
	var distance := _mouse_pos - focused_piece.position
	if distance.abs() > Vector2i.ONE:
		_jumped_this_turn = true
		var jumped_tile := _mouse_pos - (distance / 2)
		for piece in pieces:
			if piece.position == jumped_tile:
				pieces.erase(piece)
				return

	_jumped_this_turn = false


func _start_next_turn() -> void:
	if _jumped_this_turn:
		_get_available_moves()
		if true in _can_jump_either_dir:
			return

	focused_piece = null
	_jumped_this_turn = false
	highlighted_tiles.clear()

	if whose_turn == Team.PLAYER_ONE:
		whose_turn = Team.PLAYER_TWO
	else:
		whose_turn = Team.PLAYER_ONE


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
