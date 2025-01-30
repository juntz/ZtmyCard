class_name ModifyHpCommand
extends PlayerCommand

@export var hp: int


func execute_async():
	player_node.hp = hp
