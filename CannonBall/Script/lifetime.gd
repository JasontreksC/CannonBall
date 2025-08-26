class_name Lifetime extends Object

var turn: int = 0

func pass_turn() -> bool:
	if turn == 0:
		return false
		
	turn = max(turn - 1, 0)
	return true

func _init(_turn: int) -> void:
	self.turn = _turn
