class_name Player

enum SetFieldType {
	A = 0,
	B = 1,
	C = 2
}

const MAX_HP: int = 100

var battle_field_card: Card = null
var set_field_cards: Array[Card] = [null, null, null]
var abyss_cards: Array[Card] = []
var power_charger_cards: Array[Card] = []
var deck_cards: Array[Card] = []
var hand_cards: Array[Card] = []

var battle_ready: bool = false
var hp: int = MAX_HP
var power: int:
	get:
		return power_charger_cards.reduce(
			func(a: Card, b: Card):
				return a.send_to_power + b.send_to_power
		)


func _init(deck: Array[Card]):
	deck_cards = deck.duplicate()
	deck_cards.shuffle()


func draw(count: int):
	for i in range(count):
		if deck_cards.is_empty():
			return
		hand_cards.append(deck_cards.pop_back())


func discard(position: int):
	var card = hand_cards.pop_at(position)
	if card:
		abyss_cards.append(card)
