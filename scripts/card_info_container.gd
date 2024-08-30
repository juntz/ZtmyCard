extends Node2D

var card: Card


func unset_card():
	card = null
	visible = false


func set_card(value: Card, powered: bool = true):
	card = value
	visible = true
	$CardInfo.texture = card.get_child(1).texture
	$UnpoweredMask.visible = !powered
	if card.info.has("effect"):
		var desc = card.info["effect"]["description"];
		if desc.has("ko"):
			$CardInfoLabel.text = desc["ko"]
	else:
		$CardInfoLabel.text = ""
