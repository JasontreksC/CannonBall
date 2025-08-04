extends Control
class_name InGameUI

## Telescope
@onready var crTelescope: ColorRect = $Telescope
@onready var svTelescope: SubViewport = $Telescope/SubViewportContainer/SubViewport
@onready var camTelescope: Camera2D = $Telescope/SubViewportContainer/SubViewport/Camera2D

## HP
@export var hpPointSprite: PackedScene
@export var crvHPPRemoveVibration: Curve

@onready var p1HPCells: Node2D = $P1HP/HPBase/HPCells
@onready var p2HPCells: Node2D = $P2HP/HPBase/HPCells
@onready var lbFps: Label = $fps

@onready var lbP1Time: Label = $Dashboard/P1Time
@onready var lbP2Time: Label = $Dashboard/P2Time

## ShellDial
@onready var shellDial: TextureRect = $ShellDial
@onready var spShell0: Sprite2D = $ShellDial/PolygonButton_Top/SP_Shell0
@onready var spShell1: Sprite2D = $ShellDial/PolygonButton_Mid/SP_Shell1
@onready var spShell2: Sprite2D = $ShellDial/PolygonButton_Bot/SP_Shell2
@onready var spShellOutline: Sprite2D = $ShellDial/SP_Outline

var uiMgr: UIManager = null
var game: Game = null

## Telescope

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

## HP

#@rpc("any_peer", "call_local")
#func update_hp() -> void:
	#var cells = p1HPCells.get_children()
	#var count = len(cells)
	#var hpAmount = game.players[0].hp
	#if count < hpAmount:
		#for i in range(count, hpAmount):
			#var newCell: Sprite2D = hpPointSprite.instantiate() as Sprite2D
			#newCell.name = "HPP" + str(count + i)
			#newCell.position.x = 62 + 30 * i
			#if i % 2 == 1:
				#newCell.scale.y *= -1
			#p1HPCells.add_child(newCell)
	#else:
		#for i in range(hpAmount, count):
			#cells[i].free()
			#
	#points = p2HPPoints.get_children()
	#count = len(points)
	#hpAmount = game.players[1].hp
	#if count < hpAmount:
		#for i in range(count, hpAmount):
			#var newPoint: Sprite2D = hpPointSprite.instantiate() as Sprite2D
			#newPoint.name = "HPP" + str(count + i)
			#newPoint.position.x = -62 - 30 * i
			#if i % 2 == 1:
				#newPoint.scale.y *= -1
			#p2HPPoints.add_child(newPoint)
	#else:
		#for i in range(hpAmount, count):
			#points[i].free()


@rpc("any_peer", "call_local")
func generate_hp_points(player: int, count: int):
	var cells: Array[Node]
	match player:
		0:
			cells = p1HPCells.get_children()
		1:
			cells = p2HPCells.get_children()
			
	while count:
		var cell := cells.pop_front() as HPCell
		if cell and not cell.vitality:
			cell.generate()
			count -= 1
			await get_tree().create_timer(0.1).timeout

@rpc("any_peer", "call_local")
func remove_hp_points(player: int, count: int):
	var cells: Array[Node]
	match player:
		0:
			cells = p1HPCells.get_children()
		1:
			cells = p2HPCells.get_children()
	
	while count > 0:
		var cell := cells.pop_back() as HPCell
		if cell and cell.vitality:
			cell.kill()
			count -= 1
			
	## Shell Dial
func set_shell_dial(num: int):
	match num:
		0:
			spShellOutline.global_position = spShell0.global_position
		1:
			spShellOutline.global_position = spShell1.global_position
		2:
			spShellOutline.global_position = spShell2.global_position

func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

func _ready() -> void:
	if uiMgr.root.sceneMgr.currentSceneNum == 1:
		svTelescope.world_2d = uiMgr.root.get_main_viewport_world()
	
	if not multiplayer.is_server():
		shellDial.position.x += 1920
		shellDial.scale.x *= -1
	
	for i in range(20):
		var psHPCell: PackedScene = load("res://Scene/hp_cell.tscn")
		var p1HPCell: HPCell = psHPCell.instantiate() as HPCell
		if i % 2 == 1:
				p1HPCell.scale.y *= -1
		p1HPCell.position.x = 62 + 30 * i
		p1HPCells.add_child(p1HPCell)
				
		var p2HPCell: HPCell = p1HPCell.duplicate()
		p2HPCell.position.x =  -62 - 30 * i
		p2HPCells.add_child(p2HPCell)
		
	
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
		game.players[1].selectedShell = 0
	
	set_shell_dial(0)

func _on_polygon_button_mid_pressed() -> void:
	if not game:
		return
	if multiplayer.is_server():
		game.players[0].selectedShell = 1
	else:
		game.players[1].selectedShell = 1
		
	set_shell_dial(1)

func _on_polygon_button_bot_pressed() -> void:
	if not game:
		return
	if multiplayer.is_server():
		game.players[0].selectedShell = 2
	else:
		game.players[1].selectedShell = 2
		
	set_shell_dial(2)
