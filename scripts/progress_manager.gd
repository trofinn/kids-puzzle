extends Node

const SAVE_PATH := "user://progress.cfg"

var completed_levels: Array[int] = []


func _ready() -> void:
	load_progress()


func complete_level(level_id: int) -> void:
	if level_id not in completed_levels:
		completed_levels.append(level_id)
		save_progress()


func is_level_completed(level_id: int) -> bool:
	return level_id in completed_levels


func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "completed_levels", completed_levels)
	config.save(SAVE_PATH)


func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		var saved_levels: Array = config.get_value("progress", "completed_levels", [])
		completed_levels.assign(saved_levels)
