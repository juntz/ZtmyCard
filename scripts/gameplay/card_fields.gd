class_name CardFields

signal card_moved(card: Card, to: Field)

enum Field {
	NONE,
	BATTLE,
	SET_A,
	SET_B,
	SET_C,
	HAND,
	POWER_CHARGER,
	ABYSS,
	DECK,
}

var battle_field_card: CharacterCard:
	get:
		return get_last_card(Field.BATTLE)
var set_a_field_card: Card:
	get:
		return get_last_card(Field.SET_A)
var set_b_field_card: Card:
	get:
		return get_last_card(Field.SET_B)
var _deck: Array[Card]
var _card_fields: Dictionary = {}
var _card_count_limits: Dictionary = {
	Field.BATTLE: 1,
	Field.SET_A: 1,
	Field.SET_B: 1,
	Field.SET_C: 1,
}


func _init(deck: Array[Card]):
	_deck = deck.duplicate()
	for field in Field.values():
		_card_fields[field] = []
	_card_fields[Field.DECK].append_array(deck)


func card_to_idx(card: Card) -> int:
	return _deck.find(card)


func idx_to_card(idx: int) -> Card:
	return _deck[idx]


func get_last_card(field: Field) -> Card:
	var cards = _card_fields[field]
	if len(cards) <= 0:
		return null
	return cards[-1]


func get_cards(field: Field) -> Array[Card]:
	var cards: Array[Card]
	cards.assign(_card_fields[field])
	cards.make_read_only()
	return cards


func is_empty(field: Field) -> bool:
	return _card_fields[field].is_empty()


func move_card(card: Card, to: Field) -> bool:
	if _is_limit_reached(to):
		return false
	var from = _get_card_location(card)
	if from != Field.NONE:
		_card_fields[from].erase(card)
	_card_fields[to].append(card)
	card_moved.emit(card, to)
	return true


func draw_cards(count: int) -> void:
	var deck = get_cards(Field.DECK).duplicate()
	for i in count:
		var card = deck.pick_random()
		if !card:
			return
		move_card(card, Field.HAND)
		deck.erase(card)


func dump_card(card: Card) -> void:
	if card == null:
		return
	move_card(card,
			Field.POWER_CHARGER if card.send_to_power > 0
			else Field.ABYSS)


func _is_limit_reached(field: Field) -> bool:
	if !_card_count_limits.has(field):
		return false
	var limit = _card_count_limits[field]
	return len(_card_fields[field]) >= limit


func _get_card_location(card: Card) -> Field:
	for field in Field.values():
		if card in _card_fields[field]:
			return field
	return Field.NONE
