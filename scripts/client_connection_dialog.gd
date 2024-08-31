extends AcceptDialog

@export var target_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_confirmed():
	var address = $Container/AddressLineEdit.text
	var port = int($Container/PortLineEdit.text)
	if (!address or !port):
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_packed(target_scene)
