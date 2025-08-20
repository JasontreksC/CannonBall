class_name SubUIDashBoard extends TextureRect

@onready var label1: Label = $Label1
@onready var label2: Label = $Label2
@onready var pbOutter: Line2D = $ProgressBar_Outter
@onready var pbInner: Line2D = $ProgressBar_Outter/ProgressBar_Inner
@onready var amp: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

var usable_label: int = 1
var pb_x: float = 1920
# var activated_label: int = 0

@rpc("any_peer", "call_local")
func show_text(text: String, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)

	hide_text()

	match usable_label:
		1:
			tween.tween_property(label1, "position", Vector2(label1.position.x, 30), 0.25).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(label1, "modulate", Color.WHITE, 0.25).set_ease(Tween.EASE_IN_OUT)

			label1.text = text
			usable_label = 2
		2:
			tween.tween_property(label2, "position", Vector2(label1.position.x, 30), 0.25).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(label2, "modulate", Color.WHITE, 0.25).set_ease(Tween.EASE_IN_OUT)

			label2.text = text
			usable_label = 1

	if duration > 0:
		timer.start(duration)
	else:
		timer.paused = true

@rpc("any_peer", "call_local")
func hide_text() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)

	match usable_label:
		1:
			tween.tween_property(label2, "position", Vector2(label1.position.x, 0), 0.25).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(label2, "modulate", Color.TRANSPARENT, 0.25).set_ease(Tween.EASE_IN_OUT)
		2:
			tween.tween_property(label1, "position", Vector2(label1.position.x, 0), 0.25).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(label1, "modulate", Color.TRANSPARENT, 0.25).set_ease(Tween.EASE_IN_OUT)

func set_pb_time(time: float) -> void:
	create_tween().tween_property(pbOutter, "position", Vector2(0, 10), 0.25).set_ease(Tween.EASE_IN_OUT)
	create_tween().tween_property(self, "pb_x", 0, time).finished.connect(func():
		create_tween().tween_property(pbOutter, "position", Vector2(0, -10), 0.25).set_ease(Tween.EASE_IN_OUT).finished.connect(func(): pb_x = 1920)
	)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_text("상대 플레이어를\n기다리는 중...", -1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pbInner.points[1].x = pb_x


func _on_timer_timeout() -> void:
	hide_text()
