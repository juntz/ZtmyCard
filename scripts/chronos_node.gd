class_name ChronosNode
extends Node2D

var chronos: Chronos


func _process(_delta):
	$Chronos.rotation = -(chronos.time * TAU / Chronos.MAX_TIME)
