class_name CardNodeFactory

const CARD_INFO_FILE_PATH = "cards/cards.json"
static var card_info: Dictionary
static var card_scene: PackedScene = preload("res://scenes/card.tscn")
var _card_factory: CardFactory


func _init(game: Game):
	_card_factory = CardFactory.new(game)


static func _static_init():
	var card_file = FileAccess.open(CARD_INFO_FILE_PATH, FileAccess.READ)
	card_info = JSON.parse_string(card_file.get_as_text())
	card_file.close()


func from_number(number: int) -> CardNode:
	var document = card_info['cards'][number - 1]
	var card = _card_factory.from_document(document)
	var node = card_scene.instantiate()
	node.card = card
	node.description = _get_description(document)
	node.set_card_image(_get_image_path(document))
	return node


func _get_image_path(document: Dictionary) -> String:
	var image_base_path = card_info["imageBasePath"]
	var image_file_name = document["imageFileName"]
	return image_base_path.path_join(image_file_name)


func _get_description(document: Dictionary) -> String:
	var desc := ""
	desc += "ATTRIBUTE: %s\n" % document['attribute']
	desc += "POWER COST: %s\n" % document['powerCost']
	desc += "SEND TO POWER: %s\n" % document['sendToPower']
	if 'effect' in document:
		if 'description' in document['effect']:
			desc += document['effect']['description']['ko']
	else:
		desc += "NIGHT: %s / DAY: %s" % [document['attackPoint']['night'], document['attackPoint']['day']]
	return desc
