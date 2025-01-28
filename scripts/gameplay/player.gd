class_name Player

const MAX_HP: int = 100

var is_alive: bool:
	get:
		return hp > 0

var battle_ready: bool = false
var hp: int = MAX_HP
var power: int:
	get:
		return card_fields.get_cards(CardFields.Field.POWER_CHARGER).reduce(
			func(a: Card, b: Card):
				return a.send_to_power + b.send_to_power,
			0)
var card_set_limit: int = 1
var card_fields: CardFields
var _state: PlayerState
var _game: Game
var _empty_state: PlayerState:
	get:
		return PlayerStateFactory.create(Game.Phase.NONE, _game, self)


func _init(deck: Array[Card], game: Game):
	_game = game
	_state = _empty_state
	card_fields = CardFields.new(deck)


func process_phase_async(phase: Game.Phase):
	_state = PlayerStateFactory.create(phase, _game, self)
	await _state.run_async()
	_state = _empty_state


func select_card(card: Card):
	_state.select_card(card)


func player_ready():
	_state.player_ready.emit()
