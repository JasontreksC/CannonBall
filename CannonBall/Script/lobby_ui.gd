extends Control
class_name LobbyUI

var uiMgr: UIManager = null
@onready var teLobbyID: TextEdit = $LobbyIDInput
@onready var teHostPlayerName: TextEdit = $HostPlayerName
@onready var teJoinPlayerName: TextEdit = $JoinPlayerName

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bt_host_pressed() -> void:
	uiMgr.root.sceneMgr.set_scene(1)
	uiMgr.set_ui(1)
	#uiMgr.root.create_steam_socket()
	uiMgr.root.host_lobby(teHostPlayerName.text)


func _on_bt_join_pressed() -> void:
	uiMgr.root.sceneMgr.set_scene(1)
	uiMgr.set_ui(1)
	#uiMgr.root.connect_steam_socket(76561199086295015)
	uiMgr.root.join_lobby(int(teLobbyID.text), teJoinPlayerName.text)
