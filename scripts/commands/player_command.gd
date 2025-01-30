class_name PlayerCommand
extends Command

@export var player_idx: int
var player_node: PlayerNode:
	get:
		return game_master.player_nodes[player_idx]
