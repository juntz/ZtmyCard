class_name Player

@warning_ignore("unused_signal")
signal hp_changed(hp: int)
@warning_ignore("unused_signal")
signal card_moved(card: Card, to: Field)
@warning_ignore("unused_signal")
signal card_action_failed(card: Card)

enum Field {
	NONE,
	BATTLE,
	SET_A,
	SET_B,
	SET_C,
	HAND,
	POWER_CHARGER,
	ABYSS,
	DECK,
}

const MAX_HP: int = 100
