class_name PlayerContext
extends Player

var battle_ready: bool = false
var hp: int = MAX_HP
var power: int:
	get:
		return _card_fields[Field.POWER_CHARGER].reduce(
			func(a: Card, b: Card):
				return a.send_to_power + b.send_to_power,
			0)

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


func move_card(card: Card, to: Field) -> void:
	if _is_limit_reached(to):
		card_action_failed.emit(card)
		return
	var from = _get_card_location(card)
	if from != Field.NONE:
		_card_fields[from].erase(card)
	_card_fields[to].append(card)
	card_moved.emit(card, to)


func draw_cards(count: int) -> void:
	for i in count:
		var card = get_last_card(Player.Field.DECK)
		if !card:
			return
		move_card(card, Player.Field.HAND)


func dump_card(card: Card) -> void:
	if card is not GameCard:
		return
	move_card(card,
			Player.Field.POWER_CHARGER if card.send_to_power > 0
			else Player.Field.ABYSS)


func shuffle_deck():
	_card_fields[Field.DECK].shuffle()


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
