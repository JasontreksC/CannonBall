extends Control
class_name LobbyUI

var uiMgr: UIManager = null

@onready var tMySteamID: TextEdit = $IDsFromHost/MySteamID
@onready var tInviteSteamID: TextEdit = $IDsFromHost/InviteSteamID
@onready var tHostSteamID: TextEdit = $IDsFromClient/HostSteamID
@onready var tInvitedLobbyID: TextEdit = $IDsFromClient/InvitedLobbyID

func set_my_steam_id(id: int) -> void:
	tMySteamID.text = str(id)

func get_invite_steam_id() -> int:
	return int(tInviteSteamID.text)
	
func set_host_steam_id(id: int) -> void:
	tHostSteamID.text = str(id)
	
func set_invited_lobby_id(id: int) -> void:
	tInvitedLobbyID.text = str(id)

func _on_bt_host_pressed() -> void:
	uiMgr.root.sceneMgr.set_scene(1)
	uiMgr.root.host_lobby()


func _on_bt_join_pressed() -> void:
	uiMgr.root.sceneMgr.set_scene(1)
	uiMgr.root.join_lobby(int(tInvitedLobbyID.text))
	
func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

func _ready() -> void:
	tMySteamID.text = str(uiMgr.root.mySteamID)

func _process(delta: float) -> void:
	pass
