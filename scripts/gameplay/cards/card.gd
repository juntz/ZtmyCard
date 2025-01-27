class_name Card
extends Node

enum Attribute {
	DARKNESS,
	FLAME,
	ELECTRIC,
	WIND,
}

var attribute: Attribute
var clock: int
var power_cost: int
var send_to_power: int
