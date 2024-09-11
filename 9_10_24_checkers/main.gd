extends Node2D


enum Team {
	PLAYER_ONE = 1,
	PLAYER_TWO = 2
}

const CELL_SIZE = 128
const GRID_SIZE = 8
const RADIUS = 48
const INVALID_TILE = -Vector2i.ONE

var _pieces: Array[Piece]
var _highlighted_tiles: Array[Vector2i]
var _mouse_pos: Vector2i
var _focused_piece: Piece
#var _whose_turn := Team.PLAYER_ONE


func _ready() -> void:
	_create_pieces(0, 3, Team.PLAYER_TWO)
	_create_pieces(5, GRID_SIZE, Team.PLAYER_ONE)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_get_hovered_piece()
	elif event is InputEventMouseButton and event.is_action_pressed("click"):
		if _mouse_pos in _highlighted_tiles:
			_move_piece()
			return

		_get_clicked_piece()


func _draw() -> void:
	_draw_tiles()
	_draw_pieces()
	_highlight_tiles()


func _process(_delta: float) -> void:
	_get_mouse_pos()
	queue_redraw()


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
	for piece in _pieces:
		if piece.position == _mouse_pos:
			piece.is_hovered = true
		else:
			piece.is_hovered = false


func _get_clicked_piece() -> void:
	for piece in _pieces:
		if piece.position == _mouse_pos:
			_focused_piece = piece
			_highlighted_tiles.clear()
			_get_available_moves()


func _get_available_moves() -> void:
	if _focused_piece.team == Team.PLAYER_ONE:
		var upper_left := _get_tile(_focused_piece.position + -Vector2i.ONE)
		var upper_right := _get_tile(_focused_piece.position + Vector2i(1, -1))
		if not upper_left == INVALID_TILE:
			_highlighted_tiles.append(upper_left)

		if not upper_right == INVALID_TILE:
			_highlighted_tiles.append(upper_right)
	elif _focused_piece.team == Team.PLAYER_TWO:
		var lower_left := _get_tile(_focused_piece.position + Vector2i(-1, 1))
		var lower_right := _get_tile(_focused_piece.position + Vector2i.ONE)
		if not lower_left == INVALID_TILE:
			_highlighted_tiles.append(lower_left)

		if not lower_right == INVALID_TILE:
			_highlighted_tiles.append(lower_right)


func _get_tile(tile_pos: Vector2i) -> Vector2i:
	if tile_pos.x < 0 or tile_pos.x > (GRID_SIZE - 1):
		return INVALID_TILE

	if tile_pos.y < 0 or tile_pos.y > (GRID_SIZE - 1):
		return INVALID_TILE

	for piece in _pieces:
		if piece.position == tile_pos:
			if _focused_piece.team == piece.team:
				return INVALID_TILE
			else:
				# Can jump over an opponent piece
				var direction := tile_pos - _focused_piece.position
				return _get_tile(tile_pos + direction)

	return tile_pos


func _move_piece() -> void:
	var distance := _mouse_pos - _focused_piece.position
	if distance.abs() > Vector2i.ONE:
		var jumped_tile := _mouse_pos - (distance / 2)
		for piece in _pieces:
			if piece.position == jumped_tile:
				_pieces.erase(piece)
				break

	_focused_piece.position = _mouse_pos
	_focused_piece = null
	_highlighted_tiles.clear()


func _draw_tiles() -> void:
	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var color := Color.WHITE if (x + y) % 2 == 0 else Color.DARK_SLATE_BLUE
			draw_rect(
					Rect2i(Vector2i(x * CELL_SIZE, y * CELL_SIZE), Vector2i(CELL_SIZE, CELL_SIZE)),
					color,
					true
			)


func _draw_pieces() -> void:
	for piece: Piece in _pieces:
		var color: Color = _get_piece_color(piece)

		@warning_ignore("integer_division")
		var offset = CELL_SIZE / 2
		var offset_pos = Vector2i(
				(piece.position.x * CELL_SIZE) + offset,
				(piece.position.y * CELL_SIZE) + offset
		)

		draw_circle(offset_pos, RADIUS, color, true, -1, true)


func _highlight_tiles() -> void:
	for tile: Vector2i in _highlighted_tiles:
		draw_rect(Rect2i(tile * CELL_SIZE, Vector2i(CELL_SIZE, CELL_SIZE)), Color.AQUA, false, 5, true)


func _get_piece_color(piece: Piece) -> Color:
	if piece == _focused_piece:
		return Color.GRAY
	elif piece.is_hovered:
		return Color.GOLD
	elif piece.team == Team.PLAYER_ONE:
		return Color.MEDIUM_VIOLET_RED
	else:
		return Color.MIDNIGHT_BLUE


func _create_pieces(start_y: int, end_y: int, team: Team) -> void:
	for y in range(start_y, end_y):
		var start = 1 if y in [1, 5, 7] else 0
		for x in range(start, GRID_SIZE, 2):
			var piece = Piece.new()
			piece.position = Vector2i(x, y)
			piece.team = team
			_pieces.append(piece)


func _round_down(num: float) -> int:
	@warning_ignore("narrowing_conversion")
	return num - (int(num) % CELL_SIZE)


class Piece:
	var position: Vector2i
	var team := Team.PLAYER_ONE
	var is_hovered := false
