extends Button

@export_file("*.tscn") var target_scene: String


func _on_pressed():
	get_tree().change_scene_to_file(target_scene)
