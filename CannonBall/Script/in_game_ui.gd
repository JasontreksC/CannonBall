extends Control
class_name InGameUI

## Telescope
@export var aim_message: Dictionary = {
	"out_of_boundary" : "적의 진영을 벗어났습니다.",
	"min_range" : "최소 사거리입니다.",
	"max_range" : "최대 사거리입니다."
}
var aim_boundary_left_end: float = 0
var aim_boundary_right_end: float = 0
var telescopeZoomOptions: Array[float] = [0.3, 0.6, 1.0]
var zoomFinished: bool = true

@onready var crTelescope: TextureRect = $Telescope
@onready var svTelescope: SubViewport = $Telescope/SubViewport
@onready var camTelescope: Camera2D = $Telescope/SubViewport/Camera2D
@onready var lbAimMessage_Boundary: Label = $Telescope/AimMessage_Boundary
@onready var lbAimMessage_Range: Label = $Telescope/AimMessage_Range

## HP
@export var hpPointSprite: PackedScene
@onready var p1HPCells: Node2D = $P1HP/HPBase/HPCells
@onready var p2HPCells: Node2D = $P2HP/HPBase/HPCells
@onready var lbFps: Label = $fps

## ShellSelector
@onready var subuiShellSelector : SubUIShellSelector = $SubUI_ShellSelector

## DashBoard
@onready var subuiDashBoard : SubUIDashBoard = $SubUIDashBoard

var uiMgr: UIManager = null
var game: Game = null

## Telescope

func on_observe() -> void:
	if not multiplayer.is_server():
		crTelescope.position.x = 0
		
	crTelescope.visible = true

	if not aim_boundary_left_end:
		set_aim_boundary()

func off_observe() -> void:
	crTelescope.visible = false

func aim_to_cam_telescope(aimed_x: float) -> void:
	camTelescope.global_position = Vector2(aimed_x, -100)

	if aimed_x <= aim_boundary_left_end || aimed_x >= aim_boundary_right_end:
		lbAimMessage_Boundary.visible = true
	else:
		lbAimMessage_Boundary.visible = false
	

func zoom_cam_telescope(option: int) -> void:
	zoomFinished = false
	var tween: Tween = create_tween()
	tween.tween_property(camTelescope, "zoom", Vector2(telescopeZoomOptions[option], telescopeZoomOptions[option]), 0.5)
	tween.set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): zoomFinished = true)
## HP

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
	
	cells.reverse()
	for c: HPCell in cells:
		if c.vitality:
			c.kill()
			count -= 1
		if count <= 0:
			break
	
func set_aim_boundary() -> void:
	aim_boundary_left_end = game.world.vertical_boundary["p2_left_end"] - 200 if multiplayer.is_server() else game.world.vertical_boundary["p1_left_end"]
	aim_boundary_right_end = game.world.vertical_boundary["p2_right_end"] if multiplayer.is_server() else game.world.vertical_boundary["p1_right_end"] + 200

	print(aim_boundary_left_end)
	print(aim_boundary_right_end)

func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

func _ready() -> void:
	if uiMgr.root.sceneMgr.currentSceneNum == 1:
		svTelescope.world_2d = uiMgr.root.get_main_viewport_world()
	
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

func _process(delta: float) -> void:
	lbFps.text = str(Engine.get_frames_per_second())
