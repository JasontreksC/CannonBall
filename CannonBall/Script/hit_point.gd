extends Node2D
class_name HitPoint

var hitRange: float = 1000
var keepTurnCount: int = 0
var attackTo: int = 0
var landImpact: bool = true

var game: Game = null


func in_range(targetX: float) -> bool:
	var left = global_position.x - hitRange / 2
	var right = global_position.x + hitRange / 2
	
	if targetX > left and targetX < right:
		return true
	else:
		return false

func activate_hit():
	if landImpact:
		var target: Player = null
		match attackTo:
			1:
				target = game.players[0]
			2:
				target = game.players[1]
		if target and in_range(target.global_position.x):
			
			print(attackTo, ": Hit!")
			
	
	if keepTurnCount == 0:
		game.delete_object(self.name)

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
