extends Control

signal back_requested

const PieceScript := preload("res://scripts/puzzle_piece.gd")
const GRID_SIZE := 3
const PIECE_SIZE := Vector2(130, 130)
const BOARD_ORIGIN := Vector2(445, 155)
const LEVEL_ID := 1

@onready var pieces_layer: Control = $PiecesLayer
@onready var completion_panel: PanelContainer = $CompletionPanel
@onready var progress_label: Label = $TopBar/ProgressLabel

var placed_count := 0


func _ready() -> void:
	$TopBar/BackButton.pressed.connect(func(): back_requested.emit())
	$TopBar/RestartButton.pressed.connect(_restart)
	$CompletionPanel/Center/VBox/ReplayButton.pressed.connect(_restart)
	$CompletionPanel/Center/VBox/HomeButton.pressed.connect(func(): back_requested.emit())
	create_puzzle()


func create_puzzle() -> void:
	var texture := load("res://icon.svg") as Texture2D
	var start_positions := _shuffled_start_positions()
	for row in GRID_SIZE:
		for column in GRID_SIZE:
			var piece := TextureRect.new()
			var atlas := AtlasTexture.new()
			var source_size := texture.get_size() / GRID_SIZE
			atlas.atlas = texture
			atlas.region = Rect2(Vector2(column, row) * source_size, source_size)
			piece.set_script(PieceScript)
			piece.texture = atlas
			piece.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			piece.custom_minimum_size = PIECE_SIZE
			piece.size = PIECE_SIZE
			piece.position = start_positions.pop_back()
			piece.target_position = BOARD_ORIGIN + Vector2(column, row) * PIECE_SIZE
			piece.placed.connect(_on_piece_placed)
			pieces_layer.add_child(piece)
			_add_piece_number(piece, row * GRID_SIZE + column + 1)
	_update_progress()


func _add_piece_number(piece: TextureRect, number: int) -> void:
	var label := Label.new()
	label.text = str(number)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piece.add_child(label)


func _shuffled_start_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for index in GRID_SIZE * GRID_SIZE:
		var side_x := 75.0 if index % 2 == 0 else 1075.0
		var row := index / 2
		positions.append(Vector2(side_x, 110 + row * 115))
	positions.shuffle()
	return positions


func _on_piece_placed() -> void:
	placed_count += 1
	_update_progress()
	if placed_count == GRID_SIZE * GRID_SIZE:
		ProgressManager.complete_level(LEVEL_ID)
		await get_tree().create_timer(0.35).timeout
		completion_panel.show()


func _update_progress() -> void:
	progress_label.text = "%d / %d piese" % [placed_count, GRID_SIZE * GRID_SIZE]


func _restart() -> void:
	completion_panel.hide()
	placed_count = 0
	for piece in pieces_layer.get_children():
		piece.queue_free()
	await get_tree().process_frame
	create_puzzle()
