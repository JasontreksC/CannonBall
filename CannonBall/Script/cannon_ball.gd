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
var isHost = false
var peer: MultiplayerPeer = null
var lobbyID: int
var invite_sended = false

@export var player_scene: PackedScene

func _add_player(id=1):
	var player: Player = player_scene.instantiate()
	player.name = str(id)
	
	var gameScene: Game = sceneMgr.currentScene as Game
	gameScene.call_deferred("add_child", player)
	gameScene.players.append(player)

func get_main_viewport_world() -> World2D:
	return svMain.find_world_2d()
	
## STEAM
#func invite_to_lobby(remote_steam_id: int, lobbyID: int):
	#var result = Steam.sendP2PPacket(remote_steam_id,  var_to_bytes(lobbyID), Steam.P2P_SEND_UNRELIABLE)

func recieve_invite():
	var packetSize = Steam.getAvailableP2PPacketSize()
	if packetSize > 0:
		var packet = Steam.readP2PPacket(packetSize)
		
		if packet:
			var remote_steam_id = packet["remote_steam_id"]
			var invited_lobby_id = bytes_to_var(packet["data"])
			uiMgr.get_current_ui_as_lobby().teLobbyID.text = str(invited_lobby_id)
			print("invited from: ", invited_lobby_id)
			

func host_lobby():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 2)

func join_lobby(new_lobby_id : int):
	Steam.joinLobby(new_lobby_id)

func create_steam_socket():	
	peer = SteamMultiplayerPeer.new()
	peer.create_host(0)
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	
func connect_steam_socket(steam_id : int):
	peer = SteamMultiplayerPeer.new()
	peer.create_client(steam_id, 0)
	multiplayer.set_multiplayer_peer(peer)



func _ready() -> void:
	if Steam.steamInitEx(480):
		print("Steam 초기화 성공")
		print("내 Steam ID: ", Steam.getSteamID())
		Steam.connect("p2p_session_request", Callable(self, "_on_p2p_session_request"))
		Steam.connect("p2p_session_connect_fail", Callable(self, "_on_p2p_session_connect_fail"))
	else:
		print("Steam 초기화 실패")
	
	multiplayer.peer_connected.connect(
	func(id : int):
		# Tell the connected peer that we have also joined
		print(id)
	)
		
	Steam.lobby_created.connect(
	func(status: int, new_lobby_id: int):
		if status == 1:
			Steam.sendP2PPacket(76561199211664303,  var_to_bytes(new_lobby_id), Steam.P2P_SEND_RELIABLE)
			Steam.setLobbyData(new_lobby_id, "p1's lobby", 
				str(Steam.getPersonaName(), "'s Spectabulous Test Server"))
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
		
# 세션 요청 수신 시 자동 수락
func _on_p2p_session_request(remote_id: int):
	print("P2P 세션 요청 수신, 자동 수락:", remote_id)
	Steam.acceptP2PSessionWithUser(remote_id)

# 연결 실패 처리
func _on_p2p_session_connect_fail(remote_id: int, error: int):
	print("P2P 세션 연결 실패:", remote_id, "오류 코드:", error)		
	
func _process(delta: float) -> void:
	Steam.run_callbacks()
	recieve_invite()
