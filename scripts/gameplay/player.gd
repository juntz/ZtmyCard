class_name Player

var is_alive: bool:
	get:
		return _context.hp > 0

var _context: PlayerContext
var _state: PlayerState
var _states: Dictionary


func _init(context: PlayerContext, controller: Controller, chronos: Chronos):
	_context = context
	_states = {
		Game.Phase.NONE: PlayerState.new(_context),
		Game.Phase.MULLIGAN: PlayerMulliganState.new(_context),
		Game.Phase.SET: PlayerSetState.new(_context),
		Game.Phase.ENCHANT: PlayerEnchantState.new(_context),
		Game.Phase.BATTLE: PlayerBattleState.new(_context),
	}
	controller.card_selected.connect(_select_card)
	controller.player_ready.connect(_player_ready)


func process_phase_async(phase: .Phase):
	_state = _states[phase]
	_state.start()
	await _state.next_phase_ready
	_state = _states[Game.Phase.NONE]


func _select_card(card: Card):
	_state.select_card(card)


func _player_ready():
	_state.player_ready()
