extends Node2D


func _ready() -> void:
	EventBus.show_selectable_player_units.connect(_highlight_moveable_units)


func _highlight_moveable_units(unit_positions: Array[Vector2i]) -> void:
	pass
