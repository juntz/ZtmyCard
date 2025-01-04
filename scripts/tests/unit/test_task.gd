extends GutTest

signal sample_signal


func _init():
	process_thread_group = ProcessThreadGroup.PROCESS_THREAD_GROUP_SUB_THREAD
	

func test_task():
	var task = Task.new(_await_signal)
	await task.start()
	assert_true(true)


func _await_signal():
	await sample_signal
