class_name SubUIShellSelector extends NinePatchRect

@onready var selector : NinePatchRect = $Selector
@onready var amp: AnimationPlayer = $AnimationPlayer
@onready var timer : Timer = $Timer

var selected: int = 0
var expanded: bool = false
var y_props: Array[int] = [16, 113, 208]
var inGameUI: InGameUI = null

func select(num: int) -> void:
	if not expanded:
		amp.play("expand")
		expanded = true

	var tween: Tween = create_tween()
	tween.tween_property(selector, "position", Vector2(16,y_props[num]), 0.1).set_trans(Tween.TRANS_EXPO)
	timer.start(1)

	inGameUI.game.get_my_player().selectedShell = num

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	inGameUI = get_parent() as InGameUI

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("tab"):
		selected = (selected + 1) % 3
		select(selected)

func _on_timer_timeout() -> void:
	amp.play_backwards("expand")
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
