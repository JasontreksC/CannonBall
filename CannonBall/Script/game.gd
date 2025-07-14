extends Node2D
class_name Game

var root: CannonBall = null
var ui: InGameUI = null

var players: Array[Player]
var objects: Dictionary[String, Node2D]
var freeQueue: Array[String]

var G: float = 980

@rpc("any_peer", "call_local")
func spawn_object(path: String, name: String) -> void:
	if objects.has(name):
		return
	
	if multiplayer.is_server():
		var ps: PackedScene = load(path)
		var inst: Node2D = ps.instantiate()
		inst.name = name
		add_child(inst)
		objects[name] = inst
		
		var senderID = multiplayer.get_remote_sender_id()
		inst.rpc_id(senderID, "on_spawned")

@rpc("any_peer", "call_local")
func delete_object(name: String):
	if objects.has(name):
		var inst: Node2D = objects[name]
		inst.queue_free()
		objects.erase(name)
		
func get_object(name: String) -> Node2D:
	if objects.has(name):
		return objects[name]
	else:
		return null
		
func add_object(object: Node2D) -> bool:
	if objects.has(name):
		return false
	else:
		objects[object.name] = object
		return true

func _enter_tree() -> void:
	root = get_parent().root

func _ready() -> void:
	ui = root.uiMgr.get_current_ui_as_in_game()

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is Player:
		players.append(node as Player)
	else:
		add_object(node)
