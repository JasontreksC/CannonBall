class_name SubUIInputHint extends NinePatchRect

@onready var key: Label = $Key
@onready var explain: Label = $Explain
@onready var mouseL: TextureRect = $MouseL
@onready var mouseW: TextureRect = $MouseW

var input_possible: bool = true

func set_key_hint(key_name: String, hint_explain: String) -> void:
	mouseL.visible = false
	mouseW.visible = false
	key.text = key_name
	explain.text = hint_explain
	
func set_mouse_hint(mouse_num: int, hint_explain: String) -> void:
	key.visible = false
	match mouse_num:
		0:
			mouseL.visible = true
		1:
			mouseW.visible = true
	explain.text = hint_explain

func set_possibility(possible: bool) -> void:
	if possible:
		key.self_modulate.a = 0.5
		explain.self_modulate.a = 0.5
		mouseL.self_modulate.a = 0.5
		mouseW.self_modulate.a = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
