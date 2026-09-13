extends Control

const PUZZLE_SCENE := preload("res://scenes/puzzle.tscn")

@onready var home_screen: Control = $HomeScreen
@onready var play_button: Button = $HomeScreen/Center/VBox/PlayButton

var active_puzzle: Control


func _ready() -> void:
	play_button.pressed.connect(_start_puzzle)


func _start_puzzle() -> void:
	home_screen.hide()
	active_puzzle = PUZZLE_SCENE.instantiate()
	add_child(active_puzzle)
	active_puzzle.back_requested.connect(_show_home)


func _show_home() -> void:
	if is_instance_valid(active_puzzle):
		active_puzzle.queue_free()
	home_screen.show()
