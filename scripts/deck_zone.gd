extends Area2D

@export var card_scene: PackedScene
var card_offset = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	var f = FileAccess.open("cards/cards.json", FileAccess.READ)
	var json = JSON.parse_string(f.get_as_text())
	var cardInfos = json["cards"]
	cardInfos.shuffle()
	cardInfos = cardInfos.slice(0, 20)
	f.close()
	
	var i = 0
	for cardInfo in cardInfos:
		var card = card_scene.instantiate()
		card.set_info(cardInfo)
		card.position = Vector2(card_offset * i, card_offset * i)
		add_child(card)
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_cards():
	return get_children().filter(func(node): return node is Card)
