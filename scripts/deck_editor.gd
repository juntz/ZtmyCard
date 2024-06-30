extends Node2D

@export var card_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	var f = FileAccess.open("cards/cards.json", FileAccess.READ)
	var json = JSON.parse_string(f.get_as_text())
	var cardInfos = json["cards"]
	f.close()
	
	for cardInfo in cardInfos:
		var card = card_scene.instantiate()
		card.set_info(cardInfo)
		card.show_card()
		$Area2D/CardField.add_child(card)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
