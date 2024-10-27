extends CanvasLayer

@onready var _winner_label: Label = %WinnerLabel
@onready var _new_game_button: Button = %NewGameButton


func _ready() -> void:
	_winner_label.hide()
	_new_game_button.hide()


func start_game() -> void:
	$EndGameVBoxContainer.hide()


func show_winner(winner: String) -> void:
	$EndGameVBoxContainer.show()
	_winner_label.text = winner + " wins"
	_winner_label.show()
	_new_game_button.show()


func _on_new_game_button_pressed() -> void:
	get_tree().reload_current_scene()
