class_name PlayerState
## Abstract class for process user input to modify player depends on current phase.

@warning_ignore("unused_signal")
signal next_phase_ready

var _player: PlayerContext


func _init(player: PlayerContext):
	_player = player


func start():
	pass


@warning_ignore("unused_parameter")
func select_card(card: Card):
	pass


func player_ready():
	pass
