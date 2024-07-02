extends Node2D

@export var card_scene: PackedScene
var max_card_count = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	var card_file = FileAccess.open("cards/cards.json", FileAccess.READ)
	var card_json = JSON.parse_string(card_file.get_as_text())
	var cardInfos = card_json["cards"]
	card_file.close()
	
	for cardInfo in cardInfos:
		var card: Card = card_scene.instantiate()
		card.set_info(cardInfo)
		card.show_card()
		card.selectable = true
		card.card_clicked.connect(_on_card_clicked)
		card.card_entered.connect(_on_card_entered)
		card.card_exited.connect(_on_card_exited)
		$CardGroupContainer/CardField.add_child(card)
	
	var deck_file_path = "user://deck.json"
	if !FileAccess.file_exists(deck_file_path):
		return
		
	var deck_file = FileAccess.open(deck_file_path, FileAccess.READ)
	var deck_json = JSON.parse_string(deck_file.get_as_text())
	var card_numbers = deck_json["cards"]
	deck_file.close()
	
	var cards = $CardGroupContainer/CardField.cards()
	for card_number in card_numbers:
		_add_card_to_deck(cards[card_number - 1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _add_card_to_deck(card: Card):
	if $DeckContainer/Deck.cards().size() >= max_card_count:
		return
	
	var new_card = card.clone()
	new_card.show_card()
	new_card.selectable = true
	new_card.card_clicked.connect(_on_deck_card_clicked)
	new_card.card_entered.connect(_on_card_entered)
	new_card.card_exited.connect(_on_card_exited)
	var old_global_pos = new_card.global_position
	$DeckContainer/Deck.add_child(new_card)
	new_card.global_position = old_global_pos


func _on_card_clicked(card: Card):
	_add_card_to_deck(card)
	

func _on_deck_card_clicked(card: Card):
	$DeckContainer/Deck.remove_child(card)
	card.queue_free()


func _on_card_entered(card: Card):
	var locale = OS.get_locale()
	$CardInfoContainer.visible = true
	$CardInfoContainer.current_card = card
	$CardInfoContainer/UnpoweredMask.visible = false
	$CardInfoContainer/CardInfo.texture = card.get_child(1).texture
	$CardInfoContainer.visible = true
	if card.info.has("effect"):
		var desc = card.info["effect"]["description"];
		if desc.has(locale):
			$CardInfoContainer/CardInfoLabel.text = desc[locale]
	else:
		$CardInfoContainer/CardInfoLabel.text = ""


func _on_card_exited(card: Card):
	if $CardInfoContainer.current_card == card:
		$CardInfoContainer.visible = false


func _on_exit_button_pressed():
	var f = FileAccess.open("user://deck.json", FileAccess.WRITE)
	var data = {}
	data["cards"] = $DeckContainer/Deck.cards().map(func (x): return x.info["number"])
	f.store_line(JSON.stringify(data))
	f.close()
