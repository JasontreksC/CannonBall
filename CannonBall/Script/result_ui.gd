extends Control
class_name ResultUI

var uiMgr: UIManager = null

func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bt_quit_pressed() -> void:
	uiMgr.root.sceneMgr.set_scene(0)

func _on_bt_retry_pressed() -> void:
	uiMgr.root.sceneMgr.set_scene(1)
