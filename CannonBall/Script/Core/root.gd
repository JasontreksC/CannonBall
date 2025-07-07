extends Control

# Root 노드는 UI, 멀티플레이 시스템, 게임 씬을 모두 감싸고 있는 최상위 노드이다.
# 이 스크립트에서는 게임 씬 인스턴스에 대한 참조를 저장하고, 멀티플레이를 컨트롤한다.
# 또한 추후 로비 화면 -> 인게임 -> 게임종료 순서를 따르는 씬 전환 및 UI 배치도 이루어 질 것이다. 

# UI, 게임 씬 참조 저장
@onready var uiTelescope : ColorRect = $UI_Telescope
@onready var game: Node2D = $SVC_Main/SV_Main/Game
@onready var mtpSpawner: MultiplayerSpawner = $MultiplayerSpawner

# 멀티 플레이 관련 리소스
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

# 호스트 버튼 클릭 -> _add_player : 자신을 서버로 만들고 자신이 사용할 플레이어와 대포 객체를 월드에 생성한다.
func _on_bt_host_pressed() -> void:
	peer.create_server(135) # 포트번호 135번
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _add_player(id=1):
	var player: Player = player_scene.instantiate()
	player.name = str(id)
	game.call_deferred("add_child", player)
	MultiplaySystem.add_pool(player)

# 참가 버튼 클릭 : 자신을 클라이언트로 만들고 135번 포트의 로컬 호스트에 접속한다.
func _on_bt_join_pressed() -> void:
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer

# MultiplaySystem 싱글톤이 관리하는 객체 풀에다가 멀티플레이 동기화로 스폰된 객체 인스턴스를 저장한다.
# 멀티플레이 객체가 서버에서 생성되면, 클라이엔트에게도 똑같은 모습으로 생성되어야 한다.
# 서버에서는 객체가 직접 생성되는 반면, 클라 측은 MultiplayerSpawner에 의해 원격으로 생성된다.
# 즉 이 함수는 자동 스폰과 함께 발동하는 이벤트이다.
func _on_multiplayer_spawner_spawned(node: Node) -> void:
	MultiplaySystem.add_pool(node)

func _ready() -> void:
	# 만원경 SubViewport UI의 월드를 동기화
	# 만원경 안으로 보이는 월드와 플레이어가 실제로 존재하는 월드를 일치하게 하는 것이다.
	# 동일한 인스턴스를 공유하는것으로 월드가 복사되는것은 아니다.
	var world = $SVC_Main/SV_Main.find_world_2d()
	$UI_Telescope/SVC_Telescope/SV_Telescope.world_2d = world
	
	# 싱글톤 객체들이 가지고 있어야 하는 참조를 전달한다.
	UIManager.uiTelescope = self.uiTelescope
	MultiplaySystem.gameWorld = game
	MultiplaySystem.mtpSpawner = mtpSpawner
	
	
func _process(delta: float) -> void:
	pass
