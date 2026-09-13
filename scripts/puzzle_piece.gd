extends TextureRect

signal placed

var target_position := Vector2.ZERO
var dragging := false
var locked := false
var snap_distance := 52.0


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_filter = Control.MOUSE_FILTER_STOP
	pivot_offset = size / 2.0


func _on_gui_input(event: InputEvent) -> void:
	if locked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_begin_drag()
		else:
			_end_drag()
	elif event is InputEventMouseMotion and dragging:
		position += event.relative
	elif event is InputEventScreenTouch:
		if event.pressed:
			_begin_drag()
		else:
			_end_drag()
	elif event is InputEventScreenDrag and dragging:
		position += event.relative


func _begin_drag() -> void:
	dragging = true
	move_to_front()
	create_tween().tween_property(self, "scale", Vector2(1.08, 1.08), 0.1)


func _end_drag() -> void:
	if not dragging:
		return
	dragging = false
	if position.distance_to(target_position) <= snap_distance:
		position = target_position
		locked = true
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector2(0.94, 0.94), 0.08)
		tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)
		placed.emit()
	else:
		create_tween().tween_property(self, "scale", Vector2.ONE, 0.1)
