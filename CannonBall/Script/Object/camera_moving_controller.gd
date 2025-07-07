extends Node2D
class_name CameraMovingController

@onready var camera := $Camera2D

@export var MAX_SPEED = 500
@export var MIN_SPEED_FOLLOW = 100
@export var moveCurve : Curve
@export var zoomCurve : Curve

var targetNode: Node2D = null
var targetZoom : Vector2
var totalDistance : float
var prevPos : Vector2
var prevZoom : Vector2

var durationTime = 0
var elapsedTime = 0
var progress : float

func set_target_node(target_node: Node2D, duration: float) -> void:
	if targetNode:
		if targetNode.name == "temp":
			targetNode.free()
			
	targetNode = target_node
	totalDistance = global_position.distance_to(targetNode.global_position)
	
	prevPos = global_position
	durationTime = duration
	elapsedTime = 0
	progress = 0
	
func set_target_pos(target_pos: Vector2, duration: float) -> void:
	if targetNode:
		if targetNode.name == "temp":
			targetNode.free()
	targetNode = Node2D.new()
	get_node("/root").add_child(targetNode)
	targetNode.name = "temp"
	targetNode.global_position = target_pos
	totalDistance = global_position.distance_to(target_pos)
	
	prevPos = global_position
	durationTime = duration
	elapsedTime = 0
	progress = 0

func set_target_zoom(target_zoom: Vector2) -> void:
	prevZoom = camera.zoom
	targetZoom = target_zoom

func process_follow(delta: float) -> void:
	if targetNode == null:
		return
	if is_equal_approx(progress, 1):
		global_position = targetNode.global_position
		return
	elapsedTime = min(elapsedTime + delta, durationTime)
	progress = elapsedTime / durationTime
	var lerp_value = moveCurve.sample(progress)
	global_position = prevPos.lerp(targetNode.global_position, lerp_value)

func process_zoom() -> void:
	if is_equal_approx(progress, 1):
		camera.zoom = targetZoom
		return
	var lerp_value = moveCurve.sample(progress)
	camera.zoom = prevZoom.lerp(targetZoom, lerp_value)
	
func _ready() -> void:
	prevZoom = camera.zoom
	targetZoom = prevZoom
	progress = 1
	totalDistance = 0
	
func _process(delta: float) -> void:
	process_follow(delta)
	process_zoom()
