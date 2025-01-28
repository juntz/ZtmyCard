class_name EnchantCard
extends Card

var effect: CardEffect


func enchant():
	effect.apply()


func disenchant():
	effect.revoke()
