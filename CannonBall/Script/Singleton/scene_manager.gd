# 싱글톤
extends Node

var currentScene: Node2D = null

var mtpSpawner: MultiplayerSpawner
var serverPool: Dictionary

var G = 980

@rpc("any_peer", "call_local")
func spawn_scene(scene_path: String, owner_name: String, target_name: String) -> void:
	if multiplayer.is_server():
		var scene = load(scene_path)
		var instance = scene.instantiate()
		instance.name = owner_name + "_" + target_name
		currentScene.add_child(instance)
		var isAdded = add_pool(instance)

func get_pool(name: String) -> Node2D:
	return serverPool.get(name)

func add_pool(instance: Node2D) -> bool:
	if serverPool.has(instance.name):
		return false
	else:
		serverPool[instance.name] = instance
		return true
	
