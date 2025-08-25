extends NinePatchRect

@onready var exit_icon: TextureRect = $TextureRect

var ui: InGameUI = null
var input_count: int = 0
const button_color: Color = Color(1, 0, 0.35, 1)

signal pressed

func _enter_tree() -> void:
	ui = get_parent() as InGameUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	mouse_entered.connect(func(): ui.mouse_on_button = true)
	mouse_exited.connect(func(): ui.mouse_on_button = false)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		_on_pressed()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
		get_viewport().set_input_as_handled()


func _on_pressed() -> void:
	input_count += 1
	
	if input_count == 1:
		create_tween().tween_property(self, "size:x", 640, 0.5).set_trans(Tween.TRANS_SPRING)
		var color_in: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO)
		color_in.tween_property(self, "self_modulate", button_color, 0.5)
		color_in.tween_property(exit_icon, "modulate", Color.WHITE, 0.5)
	
		await get_tree().create_timer(3).timeout
		create_tween().tween_property(self, "size:x", 128, 0.5).set_trans(Tween.TRANS_SPRING)
		var color_out: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO)
		color_out.tween_property(self, "self_modulate", Color.WHITE, 0.5)
		color_out.tween_property(exit_icon, "modulate", button_color, 0.5)
		input_count = 0
		
	elif input_count == 2:
		get_tree().paused = true
		ui.game.get_my_player().set_multiplayer_authority(-1)
		ui.game.get_my_player().cannon.set_multiplayer_authority(-1)
		ui.game.root.back_to_lobby()
