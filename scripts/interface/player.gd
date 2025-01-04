class_name Player

@warning_ignore("unused_signal")
signal hp_changed(hp: int)
@warning_ignore("unused_signal")
signal card_moved(idx: int, from: Field, to: Field)
@warning_ignore("unused_signal")
signal card_action_failed(idx: int, at: Field)

enum Field {
	BATTLE,
	SET_A,
	SET_B,
	SET_C,
	ABYSS,
	POWER_CHARGER,
	DECK,
	HAND
}

const MAX_HP: int = 100
