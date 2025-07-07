# 싱글톤
extends Node

# 만원경 UI
var uiTelescope: ColorRect = null

func on_observe() -> void:
	if uiTelescope == null:
		return
		
	uiTelescope.visible = true

func off_observe() -> void:
	if uiTelescope == null:
		return
		
	uiTelescope.visible = false

func aim_to_cam_telescope(aimed_x: float) -> void:
	if uiTelescope == null:
		return
	var camTelescope : Camera2D = uiTelescope.find_child("Camera2D")
	if camTelescope:
		camTelescope.global_position.x = aimed_x
		camTelescope.global_position.y = -100

func zoom_cam_telescope(zoom_dir: int, zoom_speed: float, delta: float) -> void:
	if uiTelescope == null:
		return
	
	var camTelescope : Camera2D = uiTelescope.find_child("Camera2D")
	if camTelescope:
		var zoomValue = zoom_dir * zoom_speed * delta
		camTelescope.zoom.x += zoomValue
		camTelescope.zoom.y += zoomValue
		camTelescope.zoom = camTelescope.zoom.clamp(Vector2(0.5, 0.5), Vector2(2, 2))
		
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
