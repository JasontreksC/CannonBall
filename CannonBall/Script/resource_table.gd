extends Node
class_name ResourceTable

@export var packed_scenes: Dictionary[String, PackedScene]

func _init() -> void:
	pass

func get_scene_path(key: String) -> String:
	if key in  packed_scenes.keys():
		return packed_scenes[key].resource_path
	else:
		print("no key in resource table : %s" % key)
		return ""

func get_instantiated(key: String) -> Node:
	if key in  packed_scenes.keys():
		return packed_scenes[key].instantiate()
	else:
		print("no key in resource table : %s" % key)
		return null
