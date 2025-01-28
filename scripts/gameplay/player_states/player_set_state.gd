class_name PlayerSetState
extends PlayerState

var selected: Array[Card] = []


func run_async():
	await player_ready
	for card in selected:
		_game.chronos.time += card.clock


func select_card(card: Card) -> void:
	if card in selected:
		_unselect_card(card)
	elif card in _card_fields.get_cards(CardFields.Field.HAND):
		_select_card(card)


func _unselect_card(card: Card) -> void:
	if _card_fields.move_card(card, CardFields.Field.HAND):
		selected.erase(card)


func _select_card(card: Card) -> void:
	var dest = _get_move_destination()
	if dest == CardFields.Field.NONE:
		return
	if dest == CardFields.Field.BATTLE:
		if card is not CharacterCard:
			return
	if _card_fields.move_card(card, dest):
		selected.append(card)


func _get_move_destination() -> CardFields.Field:
	if len(selected) >= _player.card_set_limit:
		return CardFields.Field.NONE
	var fields = [
		CardFields.Field.BATTLE,
		CardFields.Field.SET_A,
		CardFields.Field.SET_B,
	]
	for field in fields:
		if _card_fields.is_empty(field):
			return field
	return CardFields.Field.NONE
