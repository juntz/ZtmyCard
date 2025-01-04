class_name Task

# Emit once when task completed.
signal _completed

var is_completed := false
var _action: Callable
var _mutex: Mutex


func _init(awaitable: Callable):
	_action = awaitable
	_mutex = Mutex.new()


static func run_async(awaitable: Callable) -> Task:
	var task = Task.new(awaitable)
	task.start()
	return task


static func wait_all_async(tasks: Array[Task]) -> void:
	for task in tasks:
		await task.wait_async()


func start() -> void:
	_start_async()


func wait_async() -> void:
	_mutex.lock()
	if is_completed:
		_mutex.unlock()
		return
	_mutex.unlock()
	await _completed


func _start_async() -> void:
	await _action.call()
	_mutex.lock()
	is_completed = true
	_completed.emit()
	_mutex.unlock()
