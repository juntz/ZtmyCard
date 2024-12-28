class_name Game

signal game_end

const MULLIGAN_CARD_COUNT:int = 5

var _players: Array[Player]
var _controllers: Array[Controller]
var _next_draw_counts: Array[int]


func _init(players: Array[Player], controllers: Array[Controller]):
	_players = players
	_controllers = controllers
	_next_draw_counts = []


func play():
	_mulligan()
	while(_is_game_end()):
		_wait_for_players_ready()
	game_end.emit()


func _mulligan():
	for player in _players:
		_next_draw_counts.append(MULLIGAN_CARD_COUNT)
	_draw_cards()
	_wait_for_players_ready()
	for player in _players:
		player.deck_cards.shuffle()
	_draw_cards()


func _draw_cards():
	for i in len(_players):
		_players[i].draw(_next_draw_counts[i])
		_next_draw_counts[i] = 0


func _wait_for_players_ready():
	await Signals.all(_controllers.map(
		func(x):
			return x.ready
	))


func _is_game_end() -> bool:
	return _players.any(
		func(p: Player):
			return p.hp <= 0
	)

func _on_hand_card_select(index: int):
	var player = _get_controlling_player()
	


func _get_controlling_player() -> Player:
	return null
