extends Node2D

var card: CardNode


func unset_card():
	card = null
	visible = false


func set_card(value: CardNode, powered: bool = true):
	card = value
	visible = true
	$CardInfo.texture = card.get_child(1).texture
	$UnpoweredMask.visible = !powered
	$CardInfoLabel.text = card.description
