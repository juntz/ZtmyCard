extends Button

@export var target_scene: PackedScene


func _on_pressed():
	get_tree().change_scene_to_packed(target_scene)
