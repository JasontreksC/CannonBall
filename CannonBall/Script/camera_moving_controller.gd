extends Node2D
class_name CameraMovingController

@onready var camera: Camera2D = $Camera2D
@onready var timer: Timer = $Timer

var MAX_SPEED: float = 5000
var MIN_SPEED: float = 10

var ACCELLER: float = 1000
var DECELLER: float = 2000
var DECELL_DISTANCE: float = 100
var Y_OFFSET: float = 300

var direction: int = 0
var speed: float = 0
var velocity: float = 0
var distance: float = 0



var targetNode: Node2D = null
var targetZoom : Vector2
var totalDistX : float = 0
var prevZoom : Vector2

var offset : Vector2
var progress : float
var zoommig: bool = false

func set_target(node: Node2D) -> void:
	targetNode = node
	if targetNode.global_position.x > self.global_position.x:
		direction = 1
	else:
		direction = -1
	
	#prevZoom = camera.zoom
	#targetZoom = Vector2(zoom, zoom)

	totalDistX = abs(self.global_position.x - targetNode.global_position.x)
	distance = totalDistX
	progress = 0
	
func set_zoom(zoom: float, dur: float) -> void:
	create_tween().tween_property(camera, "zoom", Vector2(zoom, zoom), dur).set_ease(Tween.EASE_IN_OUT)
	
func _ready() -> void:
	prevZoom = camera.zoom
	targetZoom = prevZoom
	progress = 1

func _process(delta: float) -> void:
	if targetNode:
		var displacement = targetNode.global_position.x - self.global_position.x
		if displacement > 0:
			direction = 1
		else:
			direction = -1
		distance = abs(displacement)
		speed = clamp(distance * 2, MIN_SPEED, MAX_SPEED)
		self.global_position.x = move_toward(self.global_position.x, targetNode.global_position.x, speed * delta)	
	
	else:
		speed = move_toward(speed, 0, delta * DECELLER)
		self.global_position.x += direction * speed * delta

	self.global_position.y = Y_OFFSET
	camera.position.y = -540 / camera.zoom.y
