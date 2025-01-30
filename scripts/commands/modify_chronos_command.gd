class_name ModifyChronosCommand
extends Command

@export var time: int


func execute_async():
	game_master.chronos_node.time += time
