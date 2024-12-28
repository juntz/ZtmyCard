extends GutTest

func test_full_game():
	var cards: Array[Card] = [
		Card.new(),
		Card.new(),
	]
	
	var players: Array[Player] = [
		Player.new([cards[0]]),
		Player.new([cards[1]]),
	]
	
	var game = Game.new(players)
	game.run()
