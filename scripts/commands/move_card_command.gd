class_name MoveCardCommand
extends PlayerCommand

@export var card_idx: int
@export var destination: CardFields.Field


func execute_async():
	player_node.move_card(card_idx, destination)
