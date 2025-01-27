class_name Game

enum Phase {
	NONE,
	MULLIGAN,
	SET,
	ENCHANT,
	BATTLE,
}

var chronos: Chronos
var players: Array[PlayerNode] = []
var _is_game_end: bool:
	get:
		return !players.all(
				func (p: PlayerNode):
					return p.is_alive)
var _loop_phases: Array[Game.Phase] = [
	Game.Phase.SET,
	Game.Phase.ENCHANT,
	Game.Phase.BATTLE,
]


func _init():
	chronos = Chronos.new()


func play_async():
	print("START")
	await _process_phase_async(Game.Phase.MULLIGAN)
	while(!_is_game_end):
		for phase in _loop_phases:
			print(Game.Phase.find_key(phase))
			await _process_phase_async(phase)
	print("END")


func get_opponent(player: PlayerNode):
	for p in players:
		if p != player:
			return p


func _process_phase_async(phase: Phase):
	await _foreach_player_async(func(p: PlayerNode):
		return Task.run_async(func(): await p.process_phase_async(phase)))


func _foreach_player_async(player_to_task: Callable):
	var tasks: Array[Task]
	tasks.assign(players.map(player_to_task))
	await Task.wait_all_async(tasks)
