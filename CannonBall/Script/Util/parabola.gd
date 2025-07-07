extends Node

func parabolic_movement(object: Node2D, V0: float, G: float, theta: float, t: float) -> Array:
	var x = V0 * cos(theta) * t
	var y = V0 * sin(theta) * t - 0.5 * G * pow(t, 2)
	return [x, -y]
	
