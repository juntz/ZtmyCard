extends Button

@export var target_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", 50001)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_packed(target_scene)
	
