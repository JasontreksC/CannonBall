extends Control
class_name InGameUI

## Telescope
@onready var crTelescope: ColorRect = $Telescope
@onready var svTelescope: SubViewport = $Telescope/SubViewportContainer/SubViewport
@onready var camTelescope: Camera2D = $Telescope/SubViewportContainer/SubViewport/Camera2D

## HP
@export var hpPointSprite: PackedScene

@onready var subuiHeader: TextureRect = $Header
@onready var p1HPPoints: Node2D = $Header/P1HP/HPBase/HPPoints
@onready var p2HPPoints: Node2D = $Header/P2HP/HPBase/HPPoints
@onready var lbFps: Label = $fps

@onready var lbP1Time: Label = $Header/Dashboard/P1Time
@onready var lbP2Time: Label = $Header/Dashboard/P2Time

## ShellDial
@onready var spShellDial0: Sprite2D = $ShellDial/PolygonButton_Top/SP_Shell0
@onready var spShellDial1: Sprite2D = $ShellDial/PolygonButton_Mid/SP_Shell1
@onready var spShellDial2: Sprite2D = $ShellDial/PolygonButton_Bot/SP_Shell2

var uiMgr: UIManager = null
var game: Game = null

func on_observe() -> void:
	if not multiplayer.is_server():
		crTelescope.position.x = 0
		
	crTelescope.visible = true

func off_observe() -> void:
	crTelescope.visible = false

func aim_to_cam_telescope(aimed_x: float) -> void:
	camTelescope.global_position = Vector2(aimed_x, -100)

func zoom_cam_telescope(zoom_dir: int, zoom_speed: float, delta: float) -> void:
	var zoomValue = zoom_dir * zoom_speed * delta
	camTelescope.zoom.x += zoomValue
	camTelescope.zoom.y += zoomValue
	camTelescope.zoom = camTelescope.zoom.clamp(Vector2(0.5, 0.5), Vector2(2, 2))

@rpc("any_peer", "call_local")
func set_hp(player: int, hpAmount: int):
	var target: Node2D = null
	if player == 0:
		target = p1HPPoints
	else:
		target = p2HPPoints
	
	var points = target.get_children()
	var count = len(points)
	
	if count < hpAmount:
		for i in range(count, hpAmount):
			var newPoint: Sprite2D = hpPointSprite.instantiate() as Sprite2D
			newPoint.name = "HPP" + str(count + i)
			
			if player == 0:
				newPoint.position.x = 62 + 30 * i
			else:
				newPoint.position.x = -62 - 30 * i
			
			if i % 2 == 1:
				newPoint.scale.y *= -1
			
			target.add_child(newPoint)
			
	else:
		for i in range(hpAmount, count):
			points[i].free()
	
	

func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

func _ready() -> void:
	if uiMgr.root.sceneMgr.currentSceneNum == 1:
		svTelescope.world_2d = uiMgr.root.get_main_viewport_world()
		
	set_hp(0, 20)
	set_hp(1, 20)

var sec: float = 0
var fps: float = 0
func _process(delta: float) -> void:
	sec += delta
	fps += 1
	if sec >= 1.0:
		lbFps.text = str(fps)
		sec = 0
		fps = 0
		
@rpc("any_peer", "call_local")		
func set_player_life_time(p1time: float, p2time: float) -> void:
	lbP1Time.text = "%.1f" % p1time
	lbP2Time.text = "%.1f" % p2time


func _on_polygon_button_top_pressed() -> void:
	if not game:
		return
	if multiplayer.is_server():
		game.players[0].selectedShell = 0
	else:
		game.players[1].selectedShel = 0

	spShellDial0.get_child(0).visible = true
	spShellDial1.get_child(0).visible = false
	spShellDial2.get_child(0).visible = false

func _on_polygon_button_mid_pressed() -> void:
	if not game:
		return
	if multiplayer.is_server():
		game.players[0].selectedShell = 1
	else:
		game.players[1].selectedShel = 1

	spShellDial0.get_child(0).visible = false
	spShellDial1.get_child(0).visible = true
	spShellDial2.get_child(0).visible = false

func _on_polygon_button_bot_pressed() -> void:
	if not game:
		return
	if multiplayer.is_server():
		game.players[0].selectedShell = 2
	else:
		game.players[1].selectedShel = 2

	spShellDial0.get_child(0).visible = false
	spShellDial1.get_child(0).visible = false
	spShellDial2.get_child(0).visible = true
