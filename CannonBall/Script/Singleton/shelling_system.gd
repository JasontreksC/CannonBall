# 싱글톤
extends Node

var shell_scene = preload("res://Scene/Object/shell.tscn")
var shell_instance: Shell = null
var field: Node2D = null

const G: float = 980
var p0: Vector2 = Vector2.ZERO
var v0: float = 0
var theta: float = 0
var t: float = 0
var timescale: float = 1

func _physics_process(delta: float) -> void:
	if shell_instance:		
		var result = Parabola.parabolic_movement(shell_instance, v0, G, theta, t)
		shell_instance.global_position.x = p0.x + result[0]
		shell_instance.global_position.y = p0.y + result[1]
		t += delta * timescale
		
		if shell_instance.global_position.y >= -50:
			shell_instance.free()
			shell_instance = null
	else:
		t = 0

func start_shelling(start_pos: Vector2, theta: float, V0: float) -> void:
	if shell_instance:
		print("Still Shelling!")
		return
		
	shell_instance = shell_scene.instantiate()
	field.add_child(shell_instance)
	shell_instance.global_position = start_pos
	self.p0 = start_pos
	self.v0 = V0
	self.theta = theta
	
	print(v0)
