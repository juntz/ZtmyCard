class_name Chronos

signal time_changed(emitter: Chronos)

enum Period
{
	NIGHT,
	DAY
}

const MAX_TIME = 18
const INITIAL_TIME = 4
const DAY_START = 9

var turn: int = 1
var time: int:
	get:
		return _time
	set(value):
		_time = value % MAX_TIME
		time_changed.emit(self)
var period: Period:
	get:
		return Period.NIGHT if time < DAY_START else Period.DAY

var _time: int = INITIAL_TIME
var _history: Array[int] = [ INITIAL_TIME ]


func next_turn():
	_history.append(time)
