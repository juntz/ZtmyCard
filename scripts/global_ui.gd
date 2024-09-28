extends Node


@onready var warning_scene := preload("res://scenes/warning.tscn")
var _global_root_ui : CanvasLayer = null

func send_warning(message: String):
	var warning = warning_scene.instantiate()
	warning.get_node("Label").text = message
	_global_root_ui.add_child(warning)

	warning.position.y = -200
	var tween = get_tree().create_tween()
	tween.tween_property(warning, "position:y", 100, 0.5)
	tween.tween_interval(1.0)
	tween.tween_property(warning, "modulate:a", 0, 0.5)
	tween.tween_callback(warning.queue_free)

	return warning

func _ready():
	var root = get_tree().root
	_global_root_ui = CanvasLayer.new()
	root.add_child.call_deferred(_global_root_ui)
