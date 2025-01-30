extends Button

@export var target_scene: PackedScene
@onready var peer = ENetMultiplayerPeer.new()


func _on_pressed():
	peer.create_server(50001, 1)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_packed(target_scene)
