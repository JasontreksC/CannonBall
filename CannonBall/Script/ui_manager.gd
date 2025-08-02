# 싱글톤
extends Node
class_name UIManager

@onready var root: CannonBall = $".."

@export var psLobbyUI: PackedScene
@export var psInGameUI: PackedScene
@export var psResultUI: PackedScene

var currentUI: Control = null
var currentUINum: int = -1

# 0: 로비 , 1: 인게임, 2: 종료
func set_ui(num: int):
	if not [0, 1, 2].has(num):
		return
	if currentUINum == num:
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
		2:
			currentUI = psResultUI.instantiate()
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

func get_current_ui(num: int) -> Control:
	if currentUINum != num:
		return null
	else:
		return currentUI

func _ready() -> void:
	set_ui(0)
