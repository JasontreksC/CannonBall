extends Control
class_name InGameUI

@onready var crTelescope: ColorRect = $Telescope
@onready var svTelescope: SubViewport = $Telescope/SubViewportContainer/SubViewport
@onready var lGametime: Label = $GameTime
@onready var camTelescope: Camera2D = $Telescope/SubViewportContainer/SubViewport/Camera2D

var uiMgr: UIManager = null

func on_observe() -> void:
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

func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

func _ready() -> void:
	if uiMgr.root.sceneMgr.currentSceneNum == 1:
		svTelescope.world_2d = uiMgr.root.get_main_viewport_world()
	if not multiplayer.is_server():
		crTelescope.position.x = 0
