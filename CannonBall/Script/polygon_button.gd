extends Control
class_name PolygonButton

signal pressed

@onready var polygon: Polygon2D = $Polygon2D

func _ready() -> void:
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _has_point(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, polygon.polygon)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
		get_viewport().set_input_as_handled()
