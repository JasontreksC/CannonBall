class_name SubUIShellSelector extends NinePatchRect

@onready var selector : NinePatchRect = $Selector
@onready var timer : Timer = $Timer

var selected: int = 0
var expanded: bool = false
var y_props: Array[int] = [16, 113, 208]
var ui: InGameUI = null

func select(num: int) -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "size:x", 300, 0.5).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(selector, "size:x", 360, 0.5).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(selector, "position:y", y_props[num], 0.25).set_trans(Tween.TRANS_EXPO)

	timer.start(1)
	ui.game.get_my_player().selectedShell = num

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	ui = get_parent() as InGameUI

func _ready() -> void:
	mouse_entered.connect(func(): ui.mouse_on_button = true)
	mouse_exited.connect(func(): ui.mouse_on_button = false)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("tab"):
		selected = (selected + 1) % 3
		select(selected)

func _on_timer_timeout() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "size:x", 128, 0.5).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(selector, "size:x", 128, 0.5).set_trans(Tween.TRANS_SPRING)

	# amp.play_backwards("expand")
	expanded = false

func _on_custom_button_0_pressed() -> void:
	selected = 0
	select(selected)

func _on_custom_button_1_pressed() -> void:
	selected = 1
	select(selected)

func _on_custom_button_2_pressed() -> void:
	selected = 2
	select(selected)
