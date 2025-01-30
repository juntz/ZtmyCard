class_name GameSignalProcessor

var _game: Game
var _game_master: GameMaster


func _init(game: Game, game_master: GameMaster):
	_game = game
	_game_master = game_master
	
	game.chronos.time_changed.connect(_on_time_changed)
	for player in game.players:
		player.card_moved.connect(_on_card_moved)
		player.hp_changed.connect(_on_hp_changed)


func _on_time_changed(chronos: Chronos):
	var command = ModifyChronosCommand.new()
	command.time = chronos.time
	_game_master.execute_command(command)


func _on_card_moved(player: Player, card: Card, to: CardFields.Field):
	var command = MoveCardCommand.new()
	command.player_idx = _game.players.find(player)
	command.card_idx = player.card_fields.card_to_idx(card)
	command.destination = to
	_game_master.execute_command(command)


func _on_hp_changed(player: Player):
	var command = ModifyHpCommand.new()
	command.player_idx = _game.players.find(player)
	command.hp = player.hp
	_game_master.execute_command(command)
