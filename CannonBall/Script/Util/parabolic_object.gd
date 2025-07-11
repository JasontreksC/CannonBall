extends Node
class_name ParabolicObject

var target: Node2D = null
var p0: Vector2 = Vector2.ZERO
var v0: float = 0
var theta0: float = 0
var timescale: float = 1
var t: float = 0

var limitHeight: float = 0
var isFalling: bool = false

signal resultCall

func bind_landing_event(callback: Callable, limitHeight: float = 0):
	if not is_connected("resultCall", callback):
		self.limitHeight = limitHeight
		connect("resultCall", callback)
