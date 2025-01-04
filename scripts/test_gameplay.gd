extends GutTest

func test_full_game():
	var cards: Array[Card] = [
		Card.new(),
		Card.new(),
	]
	
	var players: Array[GamePlayer] = [
		GamePlayer.new([cards[0]]),
		GamePlayer.new([cards[1]]),
	]
	
	var controllers: Array[Controller] = [
		Controller.new(),
		Controller.new(),
	]
	
	var player_controls: Array[GamePlayerControl] = [
		GamePlayerControl.new(players[0], controllers[0]),
		GamePlayerControl.new(players[1], controllers[1]),
	]
	
	FakeDisplay.new(0, players[0], gut)
	FakeDisplay.new(1, players[1], gut)
	
	var game = Game.new(player_controls)
	game.play_async()
	gut.p("Game started.")
	
	await get_tree().create_timer(1).timeout
	
	controllers[0].ready.emit()
	controllers[1].ready.emit()
	
	await game.game_end
