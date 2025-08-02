extends Node2D

var root: CannonBall = null
var ui: ResultUI

func _enter_tree() -> void:
	root = get_parent().root as CannonBall

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root.uiMgr.set_ui(2)
	ui = root.uiMgr.get_current_ui(2) as ResultUI
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
