extends Area2D

var cards_offset = 95


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_cards():
	return get_children().filter(func(node): return node is Card)


func _reposition_cards():
	var cards = get_cards()
	for i in range(cards.size()):
		cards[i].position = Vector2(cards_offset * (i - 1), 0)
		cards[i].set_order(i)


func is_more_card_available():
	return true


func add_card(card: Card):
	add_child(card)
	_reposition_cards()


func remove_card(card: Card):
	remove_child(card)
	_reposition_cards()
