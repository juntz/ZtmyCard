class_name FakeDisplay


func _init(player_id: int, player: Player, gut: GutMain):
	player.card_moved.connect(
			func(position, from, to):
				gut.p("[%s] A card moves at %s, %s to %s" % [
					player_id,
					_get_field_name(from),
					position,
					_get_field_name(to),
					]))


func _get_field_name(field: Player.Field) -> String:
	return Player.Field.find_key(field)
