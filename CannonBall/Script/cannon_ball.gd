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
	

# SceneManager 싱글톤이 관리하는 객체 풀에다가 멀티플레이 동기화로 스폰된 객체 인스턴스를 저장한다.
# 멀티플레이 객체가 서버에서 생성되면, 클라이엔트에게도 똑같은 모습으로 생성되어야 한다.
# 서버에서는 객체가 직접 생성되는 반면, 클라 측은 MultiplayerSpawner에 의해 원격으로 생성된다.
# 즉 이 함수는 자동 스폰과 함께 발동하는 이벤트이다.
#func _on_multiplayer_spawner_spawned(node: Node) -> void:
	#if node is Player:
		#SceneManager.players.append(node as Player)
	#else:
		#SceneManager.add_pool(node)

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
