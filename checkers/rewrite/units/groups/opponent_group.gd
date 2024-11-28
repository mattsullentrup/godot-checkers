extends UnitGroup


func take_turn() -> void:
	super()
	await get_tree().create_timer(0.5).timeout
	if not jumpable_units.is_empty():
		set_selected_unit(jumpable_units.front())
	else:
		set_selected_unit(moveable_units.front())

	selected_unit.move(selected_unit.available_cells.front())
