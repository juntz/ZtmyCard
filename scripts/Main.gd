class_name Main
extends Node2D

enum Phase{DRAW, SET, OPEN, READY, CLOCK, BATTLE, END}
var chronos = 5
var phase = Phase.END
var hold_phase = false


# Called when the node enters the scene tree for the first time.
func _ready():
	for player in _get_players():
		player.draw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hold_phase:
		return
	
	var next_phase = (phase + 1) % Phase.size()
	if _get_players().all(func(p): return p.ready_status[next_phase]):
		_get_players().map(func(p): p.ready_status[next_phase] = false)
		phase = next_phase
		print("Current phase: " + Phase.keys()[phase])
		_process_phase_transition()


func _process_phase_transition():
	var players = _get_players()
	if phase == Phase.DRAW:
		for player in players:
			player.draw()
	elif phase == Phase.OPEN:
		_open_cards()
	elif phase == Phase.READY:
		_ready_battle()
	elif phase == Phase.CLOCK:
		_update_chronos()
	elif phase == Phase.BATTLE:
		_battle()
	elif phase == Phase.END:
		_clean_up_battle()


func _get_players():
	return get_children().filter(
			func(node): return node is Player
		)


func _open_cards():
	var players = _get_players()
	for player in players:
		player.open_cards()
	

func _battle():
	var players = _get_players()
	var total_attack_point = players.map(
		func(p): return p.get_attack_point(is_night())
	).reduce(
		func(a, b): return a + b
	)
	for player in players:
		var damage = total_attack_point - 2 * player.get_attack_point(is_night())
		if damage < 0:
			damage = 0
		player.hit(damage)
	
	
func _update_chronos():
	var total_clocks = 0
	for player in _get_players():
		total_clocks += player.get_set_cards().map(
			func(c): return int(c.info["clock"])
		).reduce(
			func(a, b): return a + b,
			0
		)
	chronos += total_clocks
	chronos %= 18
	print("Chronos: " + str(chronos) + (" (Night)" if is_night() else " (Day)"))
	$Chronos.turn(total_clocks)


func _ready_battle():
	for player in _get_players():
		player.ready_battle()


func _clean_up_battle():
	for player in _get_players():
		player.clean_up_battle()


func is_night():
	return chronos < 9
