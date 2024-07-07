class_name Main
extends Node2D

enum Phase{DRAW, SET, OPEN, READY, CLOCK, ENCHANT, BATTLE, END}

@export var shake_time = 0.3
var shake_amount = 5.0
var shaking = false
var prev_chronos = 5
var chronos = 5
var phase = Phase.END
var hold_phase = false
# true if win
var battle_results = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.get_peers().size() <= 0:
		$AiController.acitvate()
	
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
		
	if shaking:
		var rng = RandomNumberGenerator.new()
		var x = rng.randf_range(- shake_amount, shake_amount)
		var y = rng.randf_range(- shake_amount, shake_amount)
		position = Vector2(x, y)


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
	elif phase == Phase.ENCHANT:
		_apply_enchant()
	elif phase == Phase.BATTLE:
		_battle()
	elif phase == Phase.END:
		_end_battle()


func _get_players() -> Array[Node]:
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
		battle_results[player] = true
		if damage < 0:
			player.attack(damage)
		else:
			battle_results[player] = false
			player.hit(damage)
	
	
func _update_chronos():
	prev_chronos = chronos
	var total_clocks = 0
	for player in _get_players():
		total_clocks += player.get_clock()
	chronos += total_clocks
	chronos %= 18
	print("Chronos: " + str(chronos) + (" (Night)" if is_night() else " (Day)"))
	$Chronos.turn(total_clocks)


func _apply_enchant():
	for player in _get_players():
		player.apply_enchant()


func _ready_battle():
	for player in _get_players():
		player.ready_battle()


func _end_battle():
	for player in _get_players():
		player.end_battle(battle_results[player])


func is_prev_night():
	return prev_chronos < 9


func is_night():
	return chronos < 9


func shake(amount: float):
	shake_amount = amount
	shaking = true
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = shake_time
	timer.one_shot = true
	timer.start()
	timer.connect("timeout", _on_timer_timeout)
	
	
func revert_chronos():
	var time = prev_chronos - chronos
	if time > 0:
		time = (time % 18) - 18
	$Chronos.turn(time)
	chronos = prev_chronos


func _on_timer_timeout():
	shaking = false
	position = Vector2()
