extends Control
class_name LobbyUI

var uiMgr: UIManager = null
var lobby: Lobby = null

@onready var tMySteamID: TextEdit = $IDsFromHost/MySteamID
@onready var tInviteSteamID: TextEdit = $IDsFromHost/InviteSteamID
@onready var tHostSteamID: TextEdit = $IDsFromClient/HostSteamID
@onready var tInvitedLobbyID: TextEdit = $IDsFromClient/InvitedLobbyID
@onready var vbcFirendList: VBoxContainer = $SCC_FriendList/VBC_FirendList

func set_my_steam_id(id: int) -> void:
	tMySteamID.text = str(id)

func get_invite_steam_id() -> int:
	return int(tInviteSteamID.text)

func set_invite_steam_id(id: int) -> void:
	tInviteSteamID.text = str(id)

func set_host_steam_id(id: int) -> void:
	tHostSteamID.text = str(id)
	
func set_invited_lobby_id(id: int) -> void:
	tInvitedLobbyID.text = str(id)

func _on_bt_host_pressed() -> void:
	lobby.host_lobby()


func _on_bt_join_pressed() -> void:
	lobby.join_lobby(int(tInvitedLobbyID.text))
	
func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager
	lobby = uiMgr.root.sceneMgr.currentScene as Lobby

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_bt_refresh_pressed() -> void:
	lobby.refresh_firend_list()
