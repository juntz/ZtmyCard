extends Node2D

signal card_selected(selected, unselected)

var on_card_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func start_selection(cards, on_card_clicked):
	self.on_card_clicked = on_card_clicked
	for card: Card in cards:
		card.selectable = true
		card.card_clicked.disconnect(on_card_clicked)
		card.card_clicked.connect(_on_card_clicked)
		card.reparent($SelectionField)
	visible = true
		
		
func _on_card_clicked(selected_card: Card):
	var cards = $SelectionField.cards()
	for card in cards:
		card.selectable = false
		card.card_clicked.disconnect(_on_card_clicked)
		card.card_clicked.connect(on_card_clicked)
	var unselected = cards
	unselected.erase(selected_card)
	visible = false
	card_selected.emit(selected_card, unselected)
