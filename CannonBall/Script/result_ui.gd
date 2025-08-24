extends Control
class_name ResultUI

@onready var lbResult: Label = $Result
var uiMgr: UIManager = null

func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bt_quit_pressed() -> void:
	if uiMgr.root.steamLobbyID:
		var members_num: int = Steam.getNumLobbyMembers(uiMgr.root.steamLobbyID)
		for i in range(members_num):
			var member_steam_id = Steam.getLobbyMemberByIndex(uiMgr.root.steamLobbyID, i)
			if member_steam_id != uiMgr.root.mySteamID:
				Steam.closeP2PSessionWithUser(member_steam_id)
				
		Steam.leaveLobby(uiMgr.root.steamLobbyID)
		uiMgr.root.steamLobbyID = 0

	uiMgr.root.peer.close()
	multiplayer.multiplayer_peer = null
	uiMgr.set_ui(0)
	uiMgr.root.sceneMgr.set_scene(0)
