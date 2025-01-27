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
var card_set_limit: int = 0
var card_fields: CardFields
var _state: PlayerState
var _game: Game


func _init(context: CardFields, game: Game):
	_game = game
	card_fields = context


func process_phase_async(phase: Game.Phase):
	_state = PlayerStateFactory.create(phase, _game, self)
	_state.start()
	await _state.next_phase_ready
	_state = PlayerStateFactory.create(Game.Phase.NONE, _game, self)


func select_card(card: Card):
	_state.select_card(card)


func player_ready():
	_state.player_ready()
