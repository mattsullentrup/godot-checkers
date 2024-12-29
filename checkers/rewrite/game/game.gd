extends Node2D


@onready var _ui: CanvasLayer = %UI
@onready var _units_container: UnitsContainer = %Units


func _ready() -> void:
	%BoardGenerator.generate_level()

	_units_container.battle_over.connect(_on_battle_over)
	_units_container.init()
	_units_container.start_battle()


func _on_battle_over(player_won: bool) -> void:
	_units_container.can_click = false

	%WinSound.play()
	if player_won:
		_ui.show_winner("Player")
	else:
		_ui.show_winner("Opponent")
