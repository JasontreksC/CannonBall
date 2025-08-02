extends Node
class_name SceneManager

@onready var root: CannonBall = $"../../.."

@export var psLobbyScene: PackedScene
@export var psGameScene: PackedScene
@export var psResultScene: PackedScene

var currentScene: Node2D = null
var currentSceneNum: int = -1

# 0 로비 1 게임 2 결과
func set_scene(num: int) -> void:
	if not [0, 1, 2].has(num):
		return
	
	if currentSceneNum == num:
		return
		
	currentSceneNum = num
	
	if currentScene:
		currentScene.queue_free()
		currentScene = null
	match num:
		0:
			currentScene = psLobbyScene.instantiate()
		1:
			currentScene = psGameScene.instantiate()
		2:
			currentScene = psResultScene.instantiate()
	
	call_deferred("add_child", currentScene)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
