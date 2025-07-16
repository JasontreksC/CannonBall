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
var host = false

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

func start_host() -> void:
	peer.create_server(135) # 포트번호 135번
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _add_player(id=1):
	var player: Player = player_scene.instantiate()
	player.name = str(id)
	
	var gameScene: Game = sceneMgr.currentScene as Game
	gameScene.call_deferred("add_child", player)
	gameScene.players.append(player)
	
func start_join() -> void:
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer

func get_main_viewport_world() -> World2D:
	return svMain.find_world_2d()
	
## STEAM
func request_connection(remote_steam_id: int):
	Steam.sendP2PPacket(remote_steam_id, "connect_request".to_utf8_buffer(), Steam.P2P_SEND_UNRELIABLE)

func recieve_connection():
	var packetSize = Steam.getAvailableP2PPacketSize()
	if packetSize > 0:
		var packet = Steam.readP2PPacket(packetSize)
		if packet:
			print(packet.keys())
			var remote_steam_id = packet["remote_steam_id"]
			var data = packet["data"].get_string_from_utf8()
			print("받은 메시지:", data, "보낸 사람:", remote_steam_id)


func _ready() -> void:
	if Steam.steamInit():
		print("Steam 초기화 성공")
		print("내 Steam ID: ", Steam.getSteamID())
	else:
		print("Steam 초기화 실패")
		
func _process(delta: float) -> void:
	if host:
		recieve_connection()
