class_name Lifetime extends Object

var turn: int = 0
var sec: float = 0
var callback: Callable

func pass_turn() -> bool:
	if turn == 0:
		return false
		
	turn = max(turn - 1, 0)
	return true
	
func pass_sec(delta: float) -> bool:
	if sec == 0:
		return false
		
	sec = max(sec - delta, 0)
	return true

func _init(_turn: int, _sec: float) -> void:
	self.turn = _turn
	self.sec = _sec
