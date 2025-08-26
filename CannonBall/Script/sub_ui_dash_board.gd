class_name SubUIDashBoard extends TextureRect

@onready var label1: Label = $GameStateLabels/Label1
@onready var label2: Label = $GameStateLabels/Label2
@onready var pbOutter: Line2D = $ProgressBar_Outter
@onready var pbInner: Line2D = $ProgressBar_Outter/ProgressBar_Inner
@onready var timer: Timer = $Timer

@onready var p1Info: Control = $P1Info
@onready var p1TimeLeftRing: TextureRect = $P1Info/TimeLeftRing
@onready var p1TimeLeft: Label = $P1Info/TimeLeftRing/TimeLeft
@onready var p1AttackSign: TextureRect = $P1Info/AttackSign

@onready var p2Info: Control = $P2Info
@onready var p2TimeLeftRing: TextureRect = $P2Info/TimeLeftRing
@onready var p2TimeLeft: Label = $P2Info/TimeLeftRing/TimeLeft
@onready var p2AttackSign: TextureRect = $P2Info/AttackSign


var usable_label: int = 1
var pb_x: float = 1920
var time_left_progress: float = 0
var ui: InGameUI = null
# var activated_label: int = 0

func focus_player_info(num: int) -> void:
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO)
	match num:
		0:
			tween.tween_property(p1Info, "scale", Vector2.ONE, 0.5)
			tween.tween_property(p1AttackSign, "modulate", Color.WHITE, 0.5)
		1:
			tween.tween_property(p2Info, "scale", Vector2.ONE, 0.5)
			tween.tween_property(p2AttackSign, "modulate", Color.WHITE, 0.5)

func unfocus_player_info(num: int) -> void:
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO)
	match num:
		0:
			tween.tween_property(p1Info, "scale", Vector2(0.6, 0.6), 0.5)
			tween.tween_property(p1AttackSign, "modulate", Color.TRANSPARENT, 0.5)
		1:
			tween.tween_property(p2Info, "scale", Vector2(0.6, 0.6), 0.5)
			tween.tween_property(p2AttackSign, "modulate", Color.TRANSPARENT, 0.5)

@rpc("any_peer", "call_local")
func show_text(text: String, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)

	hide_text()

	match usable_label:
		1:
			tween.tween_property(label1, "position", Vector2(label1.position.x, 30), 0.5).set_trans(Tween.TRANS_EXPO)
			tween.tween_property(label1, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_EXPO)

			label1.text = text
			usable_label = 2
		2:
			tween.tween_property(label2, "position", Vector2(label1.position.x, 30), 0.5).set_trans(Tween.TRANS_EXPO)
			tween.tween_property(label2, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_EXPO)

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
			tween.tween_property(label2, "position", Vector2(label1.position.x, 0), 0.5).set_trans(Tween.TRANS_EXPO)
			tween.tween_property(label2, "modulate", Color.TRANSPARENT, 0.5).set_trans(Tween.TRANS_EXPO)
		2:
			tween.tween_property(label1, "position", Vector2(label1.position.x, 0), 0.5).set_trans(Tween.TRANS_EXPO)
			tween.tween_property(label1, "modulate", Color.TRANSPARENT, 0.5).set_trans(Tween.TRANS_EXPO)

func set_pb_time(time: float) -> void:
	create_tween().tween_property(pbOutter, "position", Vector2(0, 10), 0.25).set_trans(Tween.TRANS_EXPO)
	create_tween().tween_property(self, "pb_x", 0, time).finished.connect(func():
		create_tween().tween_property(pbOutter, "position", Vector2(0, -10), 0.25).set_trans(Tween.TRANS_EXPO).finished.connect(func(): pb_x = 1920)
	)

func _enter_tree() -> void:
	ui = get_parent() as InGameUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_text("상대 플레이어를\n기다리는 중...", -1)
	unfocus_player_info(0)
	unfocus_player_info(1)

	p1TimeLeftRing.material = p1TimeLeftRing.material.duplicate()
	p2TimeLeftRing.material = p2TimeLeftRing.material.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pbInner.points[1].x = pb_x

	if not is_instance_valid(ui.game):
		return
	if not is_instance_valid(ui) or not is_instance_valid(ui.game):
		return
	if ui.game.stateMachine.current_state_name() == "WaitSession" or ui.game.stateMachine.current_state_name() == "EndSession":
		return

	var p1_time_left = ui.game.players[0].lifeTime
	var p2_time_left = ui.game.players[1].lifeTime

	p1TimeLeftRing.material.set("shader_parameter/progress", 1 - p1_time_left / 60.0)
	p1TimeLeft.text = "%.1f" % p1_time_left
	
	p2TimeLeftRing.material.set("shader_parameter/progress", 1 - p2_time_left / 60.0)
	p2TimeLeft.text = "%.1f" % p2_time_left

func _on_timer_timeout() -> void:
	hide_text()
