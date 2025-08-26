extends Control
class_name CustomButton

signal pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
		get_viewport().set_input_as_handled()
