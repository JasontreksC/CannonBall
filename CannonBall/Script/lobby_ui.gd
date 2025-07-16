extends Control
class_name LobbyUI

var uiMgr: UIManager = null

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bt_host_pressed() -> void:
	uiMgr.root.host = true
	#uiMgr.root.sceneMgr.set_scene(1)
	#uiMgr.set_ui(1)
	#uiMgr.root.start_host()


func _on_bt_join_pressed() -> void:
	uiMgr.root.request_connection(76561199086295015)
	#uiMgr.root.sceneMgr.set_scene(1)
	#uiMgr.set_ui(1)
	#uiMgr.root.start_join()
