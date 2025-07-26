extends Node2D
class_name Pond

@export var effetivePlayer:int = 0
@export var pondRadius: float = 440

@onready var spPondL: Sprite2D = $SP_PondL
@onready var spPondR: Sprite2D = $SP_PondL/SP_PondR

var leftX: float
var rightX: float
var depthY: float = 100

var world: World = null
var target: Player = null

func _enter_tree() -> void:
	world = get_parent() as World
	
func _ready() -> void:
	leftX = global_position.x - pondRadius
	rightX = global_position.x + pondRadius

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and not effetivePlayer == 0:
		return
	elif not multiplayer.is_server() and not effetivePlayer == 1:
		return
		
	if not world.game.gameStarted:
		return
	
	if target == null:
		target = world.game.players[effetivePlayer]
	elif in_range(target.global_position.x):
		target.isInPond = true
		var distance: float = abs(target.global_position.x - self.global_position.x)
		var t: float = inverse_lerp(pondRadius, 0, distance)
		target.global_position.y = lerp(0.0, depthY, t)

func in_range(targetX: float) -> bool:
	return targetX > leftX and targetX < rightX

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
