class_name PlayerStateFactory


static func create(phase: Game.Phase, game: Game, player: Player) -> PlayerState:
	match phase:
		Game.Phase.NONE:
			return PlayerState.new(game, player)
		Game.Phase.MULLIGAN:
			return PlayerMulliganState.new(game, player)
		Game.Phase.SET:
			return PlayerSetState.new(game, player)
		Game.Phase.ENCHANT:
			return PlayerEnchantState.new(game, player)
		Game.Phase.BATTLE:
			return PlayerBattleState.new(game, player)
	push_error("Unknown phase: %s" % phase)
	return null
