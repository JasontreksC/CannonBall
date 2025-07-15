extends Object
class_name State

var name: String
signal entry_event
signal exit_event

func register_entry(event: Callable) -> bool:
	if is_connected("entry_event", event):
		return false
	connect("entry_event", event)
	return true
	
func register_exit(event: Callable) -> bool:
	if is_connected("entry_event", event):
		return false
	connect("exit_event", event)
	return true

func trigger_entry() -> void:
	if not entry_event.is_null():
		emit_signal("entry_event")
	
func trigger_exit() -> void:
	if not entry_event.is_null():
		emit_signal("exit_event")
	
