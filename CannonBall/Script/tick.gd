class_name Tick extends Object

var current: float = 0
var interval: float = 0
var accum: int
var callback: Callable

func pass_time(delta: float) -> bool:
	if current >= interval:
		current = 0
		accum += 1
		return true
		
	current += delta
	return false
	
func _init(_interval: float, _callback: Callable) -> void:
	self.interval = _interval
	self.callback = _callback
