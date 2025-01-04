class_name Game

signal battle_started
signal game_end

var _players: Array[GamePlayerControl]
var _is_game_end: bool:
	get:
		return !_players.all(
				func (p: GamePlayerControl):
					return p.is_alive)

func _init(players: Array[GamePlayerControl]):
	_players = players


func play_async():
	print("Game started.")
	await _mulligan_async()
	while(!_is_game_end):
		print("Waiting for players ready.")
		await _wait_for_players_ready_async()
		battle_started.emit()
	game_end.emit()
	print("Game ended.")


func _wait_for_players_ready_async():
	var signals: Array[Signal]
	signals.assign(_players.map(
			func(p: GamePlayerControl):
				return p.ready))
	await Signals.all(signals)


func _mulligan_async():
	var tasks: Array[Task]
	tasks.assign(_players.map(
			func(p: GamePlayerControl):
				return Task.run_async(p.mulligan_async)))
	await Task.wait_all_async(tasks)
