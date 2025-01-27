class_name PlayerState
## Abstract class for process user input to modify player depends on current phase.

@warning_ignore("unused_signal")
signal next_phase_ready

var _game: Game
var _player: Player
@warning_ignore("unused_private_class_variable")
var _card_fields: CardFields:
	get:
		return _player.card_fields


func _init(game: Game, player: Player):
	_game = game
	_player = player


func start() -> void:
	pass


@warning_ignore("unused_parameter")
func select_card(card: Card) -> void:
	pass


func player_ready() -> void:
	pass
