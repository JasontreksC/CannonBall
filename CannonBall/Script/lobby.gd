extends Node2D
class_name Lobby

var root: CannonBall = null
var sceneMgr: SceneManager = null
var ui: LobbyUI = null

var validFriends: Dictionary[String, int]
var invalidFriends: Dictionary[String, int]
var hosting: bool = false

func host_lobby():
	hosting = true
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 2)

func join_lobby(new_lobby_id : int):
	Steam.sendP2PPacket(Steam.getLobbyOwner(new_lobby_id), var_to_bytes("client_connected"), Steam.P2P_SEND_RELIABLE)
	Steam.joinLobby(new_lobby_id)

## 친구목록 및 초대
func refresh_firend_list():
	var firendCount = Steam.getFriendCount(Steam.FriendFlags.FRIEND_FLAG_ALL)
	for i in range(0, firendCount):
		var friendID: int = Steam.getFriendByIndex(i, Steam.FriendFlags.FRIEND_FLAG_ALL)
		var friendName: String = Steam.getFriendPersonaName(friendID)
		var friendState: Steam.PersonaState = Steam.getFriendPersonaState(friendID)
		
		if friendState == Steam.PersonaState.PERSONA_STATE_ONLINE or friendState == Steam.PersonaState.PERSONA_STATE_LOOKING_TO_PLAY:
			validFriends[friendName] = friendID
		else:
			invalidFriends[friendName] = friendID
	
	if ui.vbcFirendList.get_child_count() > 0:
		for n: Node in ui.vbcFirendList.get_children():
			n.free()
	
	for f: String in validFriends.keys():
		var btValidFriend := Button.new()
		btValidFriend.size.y = 50
		btValidFriend.text = f
		btValidFriend.disabled = false
		btValidFriend.pressed.connect(_on_pressed_fb.bind(btValidFriend))
		
		ui.vbcFirendList.add_child(btValidFriend)
	
	for f: String in invalidFriends.keys():
		var btInvalidFriend := Button.new()
		btInvalidFriend.size.y = 50
		btInvalidFriend.text = f
		btInvalidFriend.disabled = true
		
		ui.vbcFirendList.add_child(btInvalidFriend)

func _on_pressed_fb(fb: Button):
	ui.set_invite_steam_id(validFriends[fb.text])

func recieve_invite():
	var packetSize = Steam.getAvailableP2PPacketSize()
	if packetSize > 0:
		var packet = Steam.readP2PPacket(packetSize)
		
		if packet:
			var remote_steam_id = packet["remote_steam_id"]
			var invited_lobby_id = bytes_to_var(packet["data"])
			
			ui.set_host_steam_id(remote_steam_id)
			ui.set_invited_lobby_id(invited_lobby_id)
			print("invited from: ", invited_lobby_id)


func _enter_tree() -> void:
	sceneMgr = get_parent() as SceneManager
	root = sceneMgr.root as CannonBall

func _ready() -> void:
	ui = root.uiMgr.get_current_ui_as_lobby()
	refresh_firend_list()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Steam.run_callbacks()
	if hosting:
		var packetSize = Steam.getAvailableP2PPacketSize()
		if packetSize > 0:
			var packet = Steam.readP2PPacket(packetSize)
			if packet:
				var remote_steam_id = packet["remote_steam_id"]
				if remote_steam_id == ui.get_invite_steam_id():
					var message = bytes_to_var(packet["data"])
					if message == "client_connected":
						hosting = false
						root.session_start()
	else:
		recieve_invite()

func _on_p2p_session_request(remote_id: int):
	print("P2P 세션 요청 수신, 자동 수락:", remote_id)
	Steam.acceptP2PSessionWithUser(remote_id)

# 연결 실패 처리
func _on_p2p_session_connect_fail(remote_id: int, error: int):
	print("P2P 세션 연결 실패:", remote_id, "오류 코드:", error)		
