extends Node2D

signal card_selected(idx)
signal _card_clicked(card)


func start_selection(player: Player, field: CardField.Field):
	var cards = player.card_fields[field].cards()
	for card: Card in cards:
		var cloned_card = card.clone()
		cloned_card.selectable = true
		cloned_card.card_clicked.connect(func(card): _card_clicked.emit(card))
		cloned_card.show_card()
		$SelectionField.add_child(cloned_card)
	visible = true
	
	var selected_card = await _card_clicked
	var idx = $SelectionField.cards().find(selected_card)
	
	for card in $SelectionField.cards():
		$SelectionField.remove_child(card)
	visible = false
	card_selected.emit(idx)
