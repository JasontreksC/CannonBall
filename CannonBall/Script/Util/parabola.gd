extends Node2D
class_name Parabola

var pool: Dictionary[String, ParabolicObject]

func start_parabola(name: String, target: Node2D, p0: Vector2, v0: float, theta0: float, timescale: float = 1):
	if pool.has(name):
		print(name, ": already started!")
		return
	
	var newPO = ParabolicObject.new()
	newPO.target = target
	newPO.p0 = p0
	newPO.v0 = v0
	newPO.theta0 = theta0
	newPO.timescale = timescale
	pool[name] = newPO

func result_parabola(name: String, limitHeight: float, callback: Callable):
	if pool.has(name):
		var po: ParabolicObject = pool.get(name)
		po.limitHeight = limitHeight
		po.bind_landing_event(callback)

func _physics_process(delta: float) -> void:
	for po in pool.values():
		po.t += delta * po.timescale
		var x = po.v0 * cos(po.theta0) * po.t
		var y = po.v0 * sin(po.theta0) * po.t - 0.5 * 980 * pow(po.t, 2)
		y *= -1
		
		if ((po.p0.y + y) - po.target.global_position.y) < 0:
			po.isFalling = false
		else:
			po.isFalling = true
		
		po.target.global_position = po.p0 + Vector2(x, y)
		
		if po.isFalling and y >= po.limitHeight:
			po.emit_signal("resultCall")

	
