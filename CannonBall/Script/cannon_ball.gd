extends Control
class_name CannonBall

@onready var sceneMgr: SceneManager = $SVC_Main/SV_Main/SceneManager
@onready var uiMgr: UIManager = $UIManager
@onready var svMain: SubViewport = $SVC_Main/SV_Main

# Root 노드는 UI, 멀티플레이 시스템, 게임 씬을 모두 감싸고 있는 최상위 노드이다.
# 이 스크립트에서는 게임 씬 인스턴스에 대한 참조를 저장하고, 멀티플레이를 컨트롤한다.
# 또한 추후 로비 화면 -> 인게임 -> 게임종료 순서를 따르는 씬 전환 및 UI 배치도 이루어 질 것이다. 

# UI, 게임 씬 참조 저장

# 멀티 플레이 관련 리소스
var app_id: int = 480 # 4442940
var my_steam_id: int = 0
var invite_steam_id: int
var host_steam_id: int
var steam_lobby_id: int = 0
var my_steam_name: String 
var invite_steam_name: String

var peer: MultiplayerPeer = null
# var local_host_ip: String = ""
# var local_join_ip: String = ""

@export var player_scene: PackedScene

@rpc("any_peer", "call_local")
func _add_player(id=1):
	if not multiplayer.is_server():
		return

	var player: Player = player_scene.instantiate()
	player.name = str(id)
	var gameScene: Game = sceneMgr.currentScene as Game
	gameScene.call_deferred("add_child", player)
	gameScene.players.append(player)

func create_steam_socket():
	peer = SteamMultiplayerPeer.new()
	peer.create_host(0)
	multiplayer.set_multiplayer_peer(peer)
	if not multiplayer.peer_connected.is_connected(_add_player):
		multiplayer.peer_connected.connect(_add_player)
	_add_player()
	
func connect_steam_socket(steam_id : int):
	peer = SteamMultiplayerPeer.new()
	peer.create_client(steam_id, 0)
	multiplayer.set_multiplayer_peer(peer)

# func create_local_socket():
# 	peer = ENetMultiplayerPeer.new()
# 	peer.create_server(135)
# 	multiplayer.set_multiplayer_peer(peer)
# 	if not multiplayer.peer_connected.is_connected(_add_player):
# 		multiplayer.peer_connected.connect(_add_player)
# 	_add_player()
	# local_hosting = true
	# print("목적지 설정: ", udp_peer.set_dest_address("127.0.0.1", UDP_PORT))
	# udp_peer.set_broadcast_enabled(true)

# func connect_local_socket():
# 	peer = ENetMultiplayerPeer.new()
# 	peer.create_client(local_join_ip, 135)
# 	multiplayer.set_multiplayer_peer(peer)
	# listening = true
	# print("리슨: ", upd_server.listen(UDP_PORT))

func get_main_viewport_world() -> World2D:
	return svMain.find_world_2d()

# func get_local_ipv4() -> String:
# 	var ipv4_17230: Array[String] = []
# 	var ipv4_105: Array[String] = []
# 	var ipv4_192168: Array[String] = []
	
# 	var adresses := IP.get_local_addresses()
# 	for a in adresses:
# 		if a.begins_with("172.30."):
# 			ipv4_17230.append(a)
# 		elif a.begins_with("10.5."):
# 			ipv4_105.append(a)
# 		elif a.begins_with("192.168."):
# 			ipv4_192168.append(a)
	
# 	if ipv4_17230:
# 		return ipv4_17230[0]
# 	elif ipv4_105:
# 		return ipv4_105[0]
# 	elif ipv4_192168:
# 		return ipv4_192168[0]
# 	else:
# 		return ""

func back_to_lobby() -> void:
	get_tree().paused = false

	if steam_lobby_id:
		var members_num: int = Steam.getNumLobbyMembers(steam_lobby_id)
		for i in range(members_num):
			var member_steam_id = Steam.getLobbyMemberByIndex(steam_lobby_id, i)
			if member_steam_id != steam_lobby_id:
				Steam.closeP2PSessionWithUser(member_steam_id)
				
		Steam.leaveLobby(steam_lobby_id)
		steam_lobby_id = 0

	peer.close()
	multiplayer.multiplayer_peer = null
	uiMgr.set_ui(0)
	sceneMgr.set_scene(0)

func steam_client_init():
	var result = Steam.steamInitEx(app_id)
	if result["status"] == 2:
		print("Steam 클라이언트가 실행중이지 않음")
		return
	
	if Steam.loggedOn():
		my_steam_id = Steam.getSteamID()
		print("Steam 초기화 성공")
		print("내 Steam ID: ", my_steam_id)
		print("내 Steam 닉네임: ", Steam.getPersonaName())
		
		Steam.connect("p2p_session_request", Callable(self, "_on_p2p_session_request"))
		Steam.connect("p2p_session_connect_fail", Callable(self, "_on_p2p_session_connect_fail"))
	else:
		print("Steam 로그인 상태가 아님")
		return

	Steam.lobby_created.connect(
	func(status: int, new_lobby_id: int):
		if status == 1:
			if invite_steam_id:
				Steam.sendP2PPacket(invite_steam_id, var_to_bytes(new_lobby_id), Steam.P2P_SEND_RELIABLE)
				print("invite sended!: ", invite_steam_id)
			
			Steam.setLobbyData(new_lobby_id, "p1's lobby", 
				str(Steam.getPersonaName(), "'s Spectabulous Test Server"))
			
			sceneMgr.set_scene(1)
			create_steam_socket()
			print("Lobby ID:", new_lobby_id)
			steam_lobby_id = new_lobby_id
		else:
			print("Error on create lobby!")
	)
	
	Steam.lobby_joined.connect(
	func (new_lobby_id: int, _permissions: int, _locked: bool, response: int):
		if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
			var id = Steam.getLobbyOwner(new_lobby_id)
			if id != Steam.getSteamID():
				if id == host_steam_id:
					sceneMgr.set_scene(1)
					connect_steam_socket(id)
					steam_lobby_id = new_lobby_id
				else:
					print("오류: 초대를 전송한 호스트의 SteamID와 로비 오너의 SteamID가 일치하지 않음.")
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

func _ready() -> void:
	uiMgr.set_ui(0)
	sceneMgr.set_scene(0)

	if not steam_client_init():
		print("Steam 초기화 실패")

	

	# print("바인딩: ", udp_peer.bind(0))
	# local_host_ip = get_local_ipv4()
	
	
func _process(delta: float) -> void:
	Steam.run_callbacks()
	
func _on_p2p_session_request(remote_id: int):
	print("P2P 세션 요청 수신, 자동 수락:", remote_id)
	Steam.acceptP2PSessionWithUser(remote_id)

func _on_p2p_session_connect_fail(remote_id: int, error: int):
	print("P2P 세션 연결 실패:", remote_id, "오류 코드:", error)
