extends Node
class_name SceneManager

@onready var root: CannonBall = $"../../.."

var psLobbyScene: PackedScene
var psGameScene: PackedScene

var currentScene: Node2D = null
var currentSceneNum: int = 0

# 0 로비 1 게임 2 결과
func set_scene(num: int) -> void:
	if num != 0 and num != 1 and num != 2:
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
	
	call_deferred("add_child", currentScene)

func _init() -> void:
	psLobbyScene = load("res://Scene/lobby.tscn")
	psGameScene = load("res://Scene/game.tscn")

func _ready() -> void:
	set_scene(0)
