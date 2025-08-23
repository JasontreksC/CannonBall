extends Node2D
class_name Result

var sceneMgr: SceneManager = null
var root: CannonBall = null
var ui: ResultUI

func _enter_tree() -> void:
	sceneMgr = get_parent() as SceneManager
	root = sceneMgr.root as CannonBall

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root.uiMgr.set_ui(2)
	ui = root.uiMgr.get_current_ui(2) as ResultUI
	print(sceneMgr.gameResult)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
