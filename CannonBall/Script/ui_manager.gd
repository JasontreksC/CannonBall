# 싱글톤
extends Node
class_name UIManager

@onready var root: CannonBall = $".."

var psLobbyUI: PackedScene
var psInGameUI: PackedScene

var currentUI: Control = null
var currentUINum: int = 0

# 0: 로비 , 1: 인게임, 2: 종료
func set_ui(num: int):
	if num != 0 and num != 1 and num != 2:
		return
	
	currentUINum = num
	
	if currentUI:
		currentUI.queue_free()
		currentUI = null
		
	match num:
		0:
			currentUI = psLobbyUI.instantiate()
		1:
			currentUI = psInGameUI.instantiate()
			
	call_deferred("add_child", currentUI)

func get_current_ui_as_lobby() -> LobbyUI:
	if currentUINum != 0:
		return null
	else:
		return currentUI as LobbyUI

func get_current_ui_as_in_game() -> InGameUI:
	if currentUINum != 1:
		return null
	else:
		return currentUI as InGameUI

func _init() -> void:
	psLobbyUI = load("res://Scene/lobby_ui.tscn")
	psInGameUI = load("res://Scene/in_game_ui.tscn")

func _ready() -> void:
	set_ui(0)
