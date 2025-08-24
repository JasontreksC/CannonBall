extends Control
class_name LobbyUI

@onready var scFriendList: ScrollContainer = $SCC_FriendList
@onready var vbcFirendList: VBoxContainer = $SCC_FriendList/VBC_FirendList
@onready var btInvite: Button = $BT_Invite
@onready var btHost: Button = $BT_Host
@onready var btJoin: Button = $BT_Join

var uiMgr: UIManager = null
var lobby: Lobby = null

func _on_bt_host_pressed() -> void:
	lobby.host_lobby()

func _on_bt_join_pressed() -> void:
	lobby.join_lobby(uiMgr.root.steam_lobby_id)
	
func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager
	lobby = uiMgr.root.sceneMgr.currentScene as Lobby

func _ready() -> void:
	if uiMgr.root.invite_steam_id:
		uiMgr.root.invite_steam_name =  Steam.getFriendPersonaName(uiMgr.root.invite_steam_id)
		scFriendList.visible = false
		btInvite.text = uiMgr.root.invite_steam_name
		btHost.disabled = false

func _process(delta: float) -> void:
	pass

func _on_bt_refresh_pressed() -> void:
	lobby.refresh_firend_list()


func _on_bt_local_host_pressed() -> void:
	lobby.local_host()


func _on_bt_local_join_pressed() -> void:
	lobby.local_join()

func _on_bt_invite_pressed() -> void:
	scFriendList.visible = not scFriendList.visible
