extends Node2D
class_name CameraMovingController

@onready var camera := $Camera2D
@onready var timer: Timer = $Timer

# @export var MAX_SPEED = 500
# @export var MIN_SPEED_FOLLOW = 100
# var followSpeed: float = 1000
# @export var moveCurve : Curve
# @export var zoomCurve : Curve

var targetNode: Node2D = null
var targetZoom : Vector2
var totalDistX : float = 0
# var prevPos : Vector2
var prevZoom : Vector2

var offset : Vector2
# var durationTime = 0
# var elapsedTime = 0
var progress : float
var zoommig: bool = false

func set_target(node: Node2D, zoom: float = camera.zoom.x) -> void:
	if targetNode:
		if targetNode.name == "temp":
			targetNode.free()
			
	targetNode = node
	prevZoom = camera.zoom
	targetZoom = Vector2(zoom, zoom)

	totalDistX = abs(self.global_position.x - targetNode.global_position.x)
	progress = 0

@rpc("any_peer", "call_local")
func zoom_out(to : float, delta : float) -> void:
	camera.zoom.x = move_toward(camera.zoom.x, to, delta)
	camera.zoom.y = move_toward(camera.zoom.y, to, delta)
	
	
func _ready() -> void:
	prevZoom = camera.zoom
	targetZoom = prevZoom
	progress = 1

func _process(delta: float) -> void:
	camera.position.y = -540 / camera.zoom.y
	offset = camera.get_screen_center_position()

	if targetNode:
		global_position = targetNode.global_position

		if totalDistX > 0:
			var pre_progress = progress
			progress = 1 - abs(offset.x - targetNode.global_position.x) / totalDistX
			progress = max(progress, pre_progress)
		else:
			progress = 1

		progress = clamp(progress, 0, 1)
		camera.zoom = prevZoom.lerp(targetZoom, progress)
