class_name ChangePhaseCommand
extends Command

@export var phase: Game.Phase


func execute_async():
	print(phase)
