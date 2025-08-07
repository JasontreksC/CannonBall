extends Object
class_name StateMachine

var states : Dictionary[String, State]
var transits : Dictionary[int, Transit]
var prev_state: State
var current_state: State
var current_transit: Transit
var current_process_time : float
var is_transit_finished : bool

func regist_state(name: String) -> bool:
	if states.has(name):
		return false
	states[name] = State.new()
	states[name].name = name
	return true
	
func regist_transit(from: String, to: String, process_time: float) -> bool:
	var key = hash(from + to)
	if transits.has(key):
		return false
	
	transits[key] = Transit.new()
	transits[key].key = key
	transits[key].process_time = process_time
	return true

func regist_state_event(name: String, exit_or_entry: String, event: Callable) -> bool:
	if states.has(name):
		if exit_or_entry == "exit":
			return states[name].regist_exit(event)
		elif exit_or_entry == "entry":
			return states[name].regist_entry(event)
	return false

func regist_transit_event(from: String, to: String, event: Callable) -> bool:
	var key = hash(from + to)
	if transits.has(key):
		var transit = transits[key]
		if transit.is_connected("transit_event", event):
			return false
		transit.connect("transit_event", event)
		return true
	return false

func init_current_state(name: String):
	current_state = states[name]

func execute_transit(to: String) -> bool:
	var key = hash(current_state.name + to)
	if not transits.has(key):
		return false
	if current_transit and current_transit.key == key:
		return false
	
	is_transit_finished = false
	current_transit = transits[key]
	current_process_time = current_transit.process_time
	current_state.trigger_exit()
	
	if current_process_time == 0:
		is_transit_finished = true
		states[to].trigger_entry()
		prev_state = current_state
		current_state = states[to]
	
	return true

func transit_back():
	if prev_state == null:
		return false
	return execute_transit(prev_state.name)

func is_state(name: String) -> bool:
	return current_state.name == name

func current_state_name() -> String:
	return current_state.name

func is_transit_process(from: String, to: String, delta: float) -> bool:
	if current_transit == null:
		return false
	if current_transit.key != hash(from + to) or is_transit_finished:
		return false
		
	if current_process_time > 0:
		current_process_time -= delta
		return  true
	else:
		current_process_time = 0
		states[to].trigger_entry()
		prev_state = current_state
		current_state = states[to]
		is_transit_finished = true
		return false

func get_state(name: String) -> State:
	return states[name]

func get_current_process_time() -> float:
	return current_process_time
	
func transit_by_input(action: StringName, to: String) -> bool:
	if Input.is_action_just_pressed(action):
		if (to == "back"):
			transit_back()
		else:
			execute_transit(to)
		return true
	else:
		return false

func break_transit():
	if not is_transit_finished:
		current_transit = null
		current_process_time = 0
		is_transit_finished = true
