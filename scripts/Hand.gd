extends Area2D

var cards_offset = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _reposition_cards():
	var cards = []
	for node in get_children():
		if node is Card:
			cards.append(node)
	
	for i in range(cards.size()):
		cards[i].position = Vector2(cards_offset * i, 0)
		cards[i].set_order(i)


func add_card(card):
	add_child(card)
	_reposition_cards()


func remove_card(card):
	remove_child(card)
	_reposition_cards()
