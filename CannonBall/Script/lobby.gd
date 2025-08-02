extends Node2D
class_name Lobby

var root: CannonBall = null
var sceneMgr: SceneManager = null
var ui: LobbyUI = null

var mySteamID: int = 0
var validFriends: Dictionary[String, int]
var invalidFriends: Dictionary[String, int]

func host_lobby():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 2)

func join_lobby(new_lobby_id : int):
	Steam.joinLobby(new_lobby_id)

func create_steam_socket():	
	root.peer = SteamMultiplayerPeer.new()
	root.peer.create_host(0)
	root.multiplayer.set_multiplayer_peer(root.peer)
	root.multiplayer.peer_connected.connect(root.session_start)
	root.session_start()
	
func connect_steam_socket(steam_id : int):
	root.peer = SteamMultiplayerPeer.new()
	root.peer.create_client(steam_id, 0)
	root.multiplayer.set_multiplayer_peer(root.peer)

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
	root.uiMgr.set_ui(0)
	ui = root.uiMgr.get_current_ui_as_lobby()
	
	if Steam.steamInitEx(480):
		mySteamID = Steam.getSteamID()
		print("Steam 초기화 성공")
		print("내 Steam ID: ", mySteamID)
		
		Steam.connect("p2p_session_request", Callable(self, "_on_p2p_session_request"))
		Steam.connect("p2p_session_connect_fail", Callable(self, "_on_p2p_session_connect_fail"))
		
		print(Steam.getPersonaName())
		ui.set_my_steam_id(mySteamID)
	else:
		print("Steam 초기화 실패")
	
	Steam.lobby_created.connect(
	func(status: int, new_lobby_id: int):
		if status == 1:
			if ui.tInviteSteamID.text:
				Steam.sendP2PPacket(ui.get_invite_steam_id(), var_to_bytes(new_lobby_id), Steam.P2P_SEND_RELIABLE)
				print("invite sended!: ", ui.get_invite_steam_id())
			
			Steam.setLobbyData(new_lobby_id, "p1's lobby", 
				str(Steam.getPersonaName(), "'s Spectabulous Test Server"))
			root.uiMgr.set_ui(1)
			root.sceneMgr.set_scene(1)
			create_steam_socket()
			print("Lobby ID:", new_lobby_id)
		else:
			print("Error on create lobby!")
	)
	
	Steam.lobby_joined.connect(
	func (new_lobby_id: int, _permissions: int, _locked: bool, response: int):
		if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
			var id = Steam.getLobbyOwner(new_lobby_id)
			if id != Steam.getSteamID():
				root.uiMgr.set_ui(1)
				sceneMgr.set_scene(1)
				connect_steam_socket(id)
		else:
		# Get the failure reason
			var FAIL_REASON: String
			match response:
				Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
					FAIL_REASON = "This lobby no longer exists."
				Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED:
					FAIL_REASON = "You don't have permission to join this lobby."
				Steam.CHAT_ROOM_ENTER_RESPONSE_FULL:
					FAIL_REASON = "The lobby is now full."
				Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR:
					FAIL_REASON = "Uh... something unexpected happened!"
				Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED:
					FAIL_REASON = "You are banned from this lobby."
				Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED:
					FAIL_REASON = "You cannot join due to having a limited account."
				Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED:
					FAIL_REASON = "This lobby is locked or disabled."
				Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN:
					FAIL_REASON = "This lobby is community locked."
				Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU:
					FAIL_REASON = "A user in the lobby has blocked you from joining."
				Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER:
					FAIL_REASON = "A user you have blocked is in the lobby."
			print(FAIL_REASON)
		)
		
	refresh_firend_list()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Steam.run_callbacks()
	recieve_invite()

func _on_p2p_session_request(remote_id: int):
	print("P2P 세션 요청 수신, 자동 수락:", remote_id)
	Steam.acceptP2PSessionWithUser(remote_id)

# 연결 실패 처리
func _on_p2p_session_connect_fail(remote_id: int, error: int):
	print("P2P 세션 연결 실패:", remote_id, "오류 코드:", error)		
