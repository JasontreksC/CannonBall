extends Node2D
class_name Lobby

var root: CannonBall = null
var sceneMgr: SceneManager = null
var ui: LobbyUI = null

var validFriends: Dictionary[String, int]
var invalidFriends: Dictionary[String, int]
var hosting: bool = false

var selected_public_lobby_id: int = 0

func host_lobby(private: bool):
	hosting = true

	if private:
		Steam.createLobby(Steam.LOBBY_TYPE_PRIVATE, 2)
	else:
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 2)

func join_lobby(new_lobby_id : int):
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
	root.invite_steam_id = validFriends[fb.text]
	root.invite_steam_name =  Steam.getFriendPersonaName(validFriends[fb.text])
	ui.scFriendList.visible = false
	ui.btInvite.text = root.invite_steam_name
	ui.btHost.disabled = false

# func recieve_invite():
# 	var packetSize = Steam.getAvailableP2PPacketSize()
# 	if packetSize > 0:
# 		var packet = Steam.readP2PPacket(packetSize)
		
# 		if packet:
# 			var remote_steam_id = packet["remote_steam_id"]
# 			var invited_lobby_id = bytes_to_var(packet["data"])
			
# 			root.invited_steam_id = remote_steam_id
# 			root.invited_lobby_id = invited_lobby_id

# 			ui.btJoin.text = "Accept invite from: " + Steam.getFriendPersonaName(root.invited_steam_id)
# 			ui.btJoin.disabled = false

# 			print("invited from: ", invited_lobby_id)

## 공개 매치 목록 가져오기
func refresh_public_list():
	if ui.vbcPublicList.get_child_count() > 0:
		for n: Node in ui.vbcPublicList.get_children():
			n.free()

	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_DEFAULT)
	Steam.addRequestLobbyListFilterSlotsAvailable(1)
	Steam.requestLobbyList()

func _on_pressed_lb(lb: Button):
	selected_public_lobby_id = lb.get_meta('lobby_id')
	ui.btFindPublic.text = lb.text
	ui.scPublicList.visible = false
	ui.btJoinPublic.disabled = false

func _enter_tree() -> void:
	sceneMgr = get_parent() as SceneManager
	root = sceneMgr.root as CannonBall

func _ready() -> void:
	ui = root.uiMgr.get_current_ui_as_lobby()

	# 공개 목록 구성 이벤트
	Steam.lobby_match_list.connect(
	func(lobbies: Array):
		print(lobbies)

		for id: int in lobbies:
			var game_name = Steam.getLobbyData(id, "game")
			if game_name != "cannonball":
				continue

			var lobby_name = Steam.getLobbyData(id, "lobby_name")

			var btPublic := Button.new()
			btPublic.size.y = 50
			btPublic.text = lobby_name if lobby_name else str(id)
			btPublic.set_meta('lobby_id', id)

			btPublic.pressed.connect(_on_pressed_lb.bind(btPublic))

			ui.vbcPublicList.add_child(btPublic)
	)

	# 초대를 받았을 때 이벤트
	Steam.join_requested.connect(
		func(lobby_id: int, friend_id: int):
			root.invited_lobby_id = lobby_id
			root.invited_steam_id = friend_id
			ui.btJoin.text = "Accept invite from: " + Steam.getFriendPersonaName(root.invited_steam_id)
			ui.btJoin.disabled = false
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# if sceneMgr.currentSceneNum == 0:
	# 	if not hosting and root.my_steam_id:
	# 		recieve_invite()
		
