class_name Controller
extends Node

@warning_ignore("unused_signal")
signal player_ready
@warning_ignore("unused_signal")
signal card_selected(idx: int)


@warning_ignore("unused_parameter")
func request_select_cards_async(cards: Array[int], min_count=0, max_count=-1) -> Array[int]:
	push_warning("You must override and implement this method.")
	var result:Array[int] = []
	@warning_ignore("redundant_await")
	return await result
