extends Node2D

var chronos = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var players = _get_players()
	if players.all(func(p): return p.battle_ready):
		_ready_battle()
		_update_chronos()
		_battle()
		_fix_cards()
		for player in players:
			player.battle_ready = false


func _get_players():
	return get_children().filter(func(node): return node is Player)


func _fix_cards():
	var players = _get_players()
	for player in players:
		for card in player.get_set_cards():
			card.selectable = false
	

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
		player.hp -= damage
	
	
func _update_chronos():
	for player in _get_players():
		chronos += player.get_battle_field_card().clock
		chronos += player.get_set_field_cards().map(
			func(c): return c.clock
		).reduce(
			func(a, b): return a + b,
			0
		)
	chronos %= 18
	$TimeLabel.text = "Chronos: " + str(chronos) + (" (Night)" if is_night() else " (Day)")


func _ready_battle():
	for player in _get_players():
		player.ready_battle()


func is_night():
	return chronos < 9
