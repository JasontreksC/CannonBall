extends NinePatchRect

@export var interaction_texts: Dictionary[String, String] = {
	"b_pond" : "연못: 화염탄 피해 절감",
	"b_bush" : "덤불: 은신",
	"t_fire" : "화염 필드: 1초당 1 틱 대미지",
	"t_pond" : "독 연못: 2초당 1 틱 대미지",
}
@export var interaction_colors: Dictionary[String, Color] = {
	"b_pond" : Color.AQUAMARINE,
	"b_bush" : Color.GRAY,
	"t_fire" : Color.RED,
	"t_pond" : Color.PURPLE
}

@onready var symbol: TextureRect = $InteractionSymbol
@onready var label: Label = $InteractionSymbol/Label
@onready var timer: Timer = $Timer

var interaction: String = "b_bush"
var expanded: bool = false

signal pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	label.text = interaction_texts[interaction]
	label.label_settings.font_color = interaction_colors[interaction]
	symbol.texture = load("res://Asset/ui/%s.png" % interaction)
	symbol.modulate = interaction_colors[interaction]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
		get_viewport().set_input_as_handled()

func _on_pressed() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "size", Vector2(640, 128), 0.25).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "position", Vector2(-480, self.position.y), 0.25).set_trans(Tween.TRANS_BOUNCE)
	timer.start(2)


func _on_timer_timeout() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "size", Vector2(128, 128), 0.25).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "position", Vector2(-96, self.position.y), 0.25).set_trans(Tween.TRANS_BOUNCE)
