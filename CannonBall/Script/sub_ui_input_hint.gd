class_name SubUIInputHint extends Control

@onready var npr: NinePatchRect = $NinePatchRect
@onready var hbox: HBoxContainer = $NinePatchRect/HBoxContainer
@onready var trMouses: Array[TextureRect] = [
	$NinePatchRect/HBoxContainer/MouseL,
	$NinePatchRect/HBoxContainer/MouseW
]
@onready var lbKey: Label = $NinePatchRect/HBoxContainer/Key
@onready var lbExplain: Label = $NinePatchRect/HBoxContainer/Explain

@export var mouse0: bool
@export var mouse1: bool
@export var key: String
@export var explain: String
@export var pannel_length: Vector2

var attatch_target: Node2D = null
var attatch_offset: Vector2 = Vector2.ZERO

var is_tween_playing: bool = false

func show_attatch(target: Node2D, offset: Vector2 = Vector2.ZERO):
	attatch_target = target
	attatch_offset = offset
	visible = true

func show_absolute(screen_pos: Vector2):
	global_position = screen_pos
	visible = true

func hide_hint():
	if is_tween_playing:
		return
	if not visible:
		return
	
	var tween: Tween = create_tween().set_parallel().set_trans(Tween.TRANS_SPRING)
	tween.tween_property(npr, "size:x", pannel_length.x, 0.5)
	tween.tween_property(npr, "position:x", pannel_length.x / -2, 0.5)
	is_tween_playing = true
	tween.finished.connect(func():
		visible = false	
		is_tween_playing = false
	)

func _ready() -> void:
	self.scale = Vector2(0.5, 0.5)
	npr.position.x = pannel_length.x / -2
	npr.size.x = pannel_length.x

	trMouses[0].visible = mouse0
	trMouses[1].visible = mouse1
	if key.is_empty():
		lbKey.visible = false
	else:
		lbKey.text = key
	lbExplain.text = explain

func _process(delta: float) -> void:
	if attatch_target:
		var screen_pos = attatch_target.get_screen_transform().get_origin()
		self.global_position = screen_pos + attatch_offset

func _on_visibility_changed() -> void:
	if self.visible == true:
		if is_tween_playing:
			return

		var tween: Tween = create_tween().set_parallel().set_trans(Tween.TRANS_SPRING)
		tween.tween_property(npr, "size:x", pannel_length.y, 0.5)
		tween.tween_property(npr, "position:x", pannel_length.y / -2, 0.5)
		is_tween_playing = true
		tween.finished.connect(func(): is_tween_playing = false)
