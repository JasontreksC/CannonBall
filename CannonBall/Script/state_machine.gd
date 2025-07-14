extends Object
class_name StateMachine

var states : Dictionary[String, State]
var transits : Dictionary[int, Transit]
var prev_state = State.new()
var current_state = State.new()
var current_transit = Transit.new()
var current_process_time : float
var is_transit_finished : bool

func register_state(name: String) -> bool:
	if states.has(name):
		return false
	states[name] = State.new()
	states[name].name = name
	return true
	
func register_transit(from: String, to: String, process_time: float) -> bool:
	var key = hash(from + to)
	if transits.has(key):
		return false
	
	transits[key] = Transit.new()
	transits[key].key = key
	transits[key].process_time = process_time
	return true

func register_state_event(name: String, exit_or_entry: String, event: Callable) -> bool:
	if states.has(name):
		if exit_or_entry == "exit":
			return states[name].register_exit(event)
		elif exit_or_entry == "entry":
			return states[name].register_entry(event)
	return false
	
func init_current_state(name: String):
	current_state = states[name]

func transit(to: String) -> bool:
	var key = hash(current_state.name + to)
	if not transits.has(key):
		return false
	if current_transit.key == key:
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
	return transit(prev_state.name)

func is_state(name: String) -> bool:
	return current_state.name == name

func current_state_name() -> String:
	return current_state.name

func is_transit_process(from: String, to: String, delta: float) -> bool:
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

func get_transit_process_time() -> float:
	return current_transit.process_time
	
func transit_by_input(action: StringName, to: String) -> bool:
	if Input.is_action_just_pressed(action):
		if (to == "back"):
			transit_back()
		else:
			transit(to)
		return true
	else:
		return false
