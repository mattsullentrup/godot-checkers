class_name Visuals
extends Node2D


var cell_size: int
var grid_size: int
var focused_piece: Main.Piece
var highlighted_tiles: Array[Vector2i]


func _draw() -> void:
	_draw_tiles()
	_draw_pieces()
	_highlight_tiles()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw_pieces() -> void:
	for piece: Main.Piece in get_parent().pieces:
		var color: Color = _get_piece_color(piece)

		@warning_ignore("integer_division")
		var offset = cell_size / 2
		var offset_pos = Vector2i(
				(piece.position.x * cell_size) + offset,
				(piece.position.y * cell_size) + offset
		)

		draw_circle(offset_pos, Main.RADIUS, color, true, -1, true)


func _highlight_tiles() -> void:
	for tile: Vector2i in highlighted_tiles:
		draw_rect(
				Rect2i(tile * cell_size, Vector2i(cell_size, cell_size)),
				Color.AQUA, false,
				5, true
		)


func _get_piece_color(piece: Main.Piece) -> Color:
	if piece == focused_piece:
		return Color.GRAY
	elif piece.is_hovered:
		return Color.GOLD
	elif piece.team == Main.Team.PLAYER_ONE:
		return Color.MEDIUM_VIOLET_RED
	else:
		return Color.MIDNIGHT_BLUE


func _draw_tiles() -> void:
	for y in grid_size:
		for x in grid_size:
			var color := Color.WHITE if (x + y) % 2 == 0 else Color.DARK_SLATE_BLUE
			draw_rect(
					Rect2i(Vector2i(x * cell_size, y * cell_size), Vector2i(cell_size, cell_size)),
					color,
					true
			)
