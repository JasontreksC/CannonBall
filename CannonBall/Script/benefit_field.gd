extends Node2D
class_name BenefitField

@export var benefitRange:float = 500;
@export var effetivePlayer:int = 0;
@export var benefitType: int = 0;

var world: World = null
var target: Player = null

func _enter_tree() -> void:
	world = get_parent() as World
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if not world.game.gameStarted:
		return
	
	if not multiplayer.is_server():
		return
	
	if target == null:
		target = world.game.players[effetivePlayer]
	match benefitType : 
			0:#연못
				if in_range(target.global_position.x):
					target.speed = 200
				else:
					target.speed = 300
			1:#덤불
				if in_range(target.global_position.x):
					target.visible = false
				else:
					target.visible = true

		
	
func in_range(targetX: float) -> bool:
	var left = global_position.x - benefitRange / 2
	var right = global_position.x + benefitRange / 2
	
	if targetX > left and targetX < right:
		return true
	else:
		return false
				
func _process(delta: float) -> void:
	pass
