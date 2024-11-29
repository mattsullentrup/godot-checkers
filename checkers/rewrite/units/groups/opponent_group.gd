extends UnitGroup


func take_turn() -> void:
	super()
	#await get_tree().create_timer(0.5).timeout
	if not jumpable_units.is_empty():
		set_selected_unit(jumpable_units.front())
	elif not moveable_units.is_empty():
		set_selected_unit(moveable_units.front())

	if selected_unit:
		selected_unit.move(selected_unit.available_cells.front())


func _on_unit_movement_completed(unit: Unit) -> void:
	super(unit)
	if unit.can_move:
		take_turn()
