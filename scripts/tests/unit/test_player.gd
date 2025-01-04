extends GutTest

signal a


func test_assert_eq_number_not_equal():
	var t1 = test.call()
	var t2 = test.call()
	await t1
	await t2
	


func wait():
	await a

func test():
	await get_tree().create_timer(1.0).timeout
	a.emit()
