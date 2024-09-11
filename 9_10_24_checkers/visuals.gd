class_name Visuals
extends Node2D


const RADIUS = 48
const WIDTH = 5

@onready var _parent := get_parent() as Main


func _draw() -> void:
	_draw_tiles()
	_draw_pieces()
	_highlight_tiles()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw_tiles() -> void:
	for y in _parent.GRID_SIZE:
		for x in _parent.GRID_SIZE:
			var color := Color.WHITE if (x + y) % 2 == 0 else Color.DARK_SLATE_BLUE
			draw_rect(
					Rect2i(
							Vector2i(x * _parent.CELL_SIZE, y * _parent.CELL_SIZE),
							Vector2i(_parent.CELL_SIZE, _parent.CELL_SIZE)
					),
					color,
					true
			)


func _draw_pieces() -> void:
	for piece: Main.Piece in _parent.pieces:
		var color: Color = _get_piece_color(piece)

		@warning_ignore("integer_division")
		var offset = _parent.CELL_SIZE / 2
		var offset_pos = Vector2i(
				(piece.position.x * _parent.CELL_SIZE) + offset,
				(piece.position.y * _parent.CELL_SIZE) + offset
		)

		draw_circle(offset_pos, RADIUS, color, true, -1, true)


func _highlight_tiles() -> void:
	for tile: Vector2i in _parent.highlighted_tiles:
		draw_rect(
				Rect2i(tile * _parent.CELL_SIZE, Vector2i(_parent.CELL_SIZE, _parent.CELL_SIZE)),
				Color.AQUA, false,
				WIDTH, true
		)


func _get_piece_color(piece: Main.Piece) -> Color:
	if piece == _parent.focused_piece:
		return Color.GRAY
	elif piece.is_hovered:
		return Color.GOLD
	elif piece.team == Main.Team.PLAYER_ONE:
		return Color.MEDIUM_VIOLET_RED
	else:
		return Color.MIDNIGHT_BLUE
