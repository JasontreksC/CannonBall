extends Control

var uiMgr: UIManager = null

func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_shell_selector_pressed() -> void:
	uiMgr.root.sceneMgr
	pass # Replace with function body.
