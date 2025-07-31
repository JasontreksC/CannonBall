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
		
	if currentSceneNum == 0 and num == 1:
		on_enter_game_scene()
		
	elif currentSceneNum == 1 and num ==2:
		on_enter_end_scene()
	
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

func _process(delta: float) -> void:
	pass
	
func on_enter_game_scene():
	pass
	
func on_enter_end_scene():
	pass
