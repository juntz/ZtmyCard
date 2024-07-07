extends Button

@export var target_scene: PackedScene
@onready var peer = ENetMultiplayerPeer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	peer.create_server(50001, 1)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_packed(target_scene)
